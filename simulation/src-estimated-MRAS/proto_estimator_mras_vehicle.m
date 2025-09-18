function [state_hat, diag, v_corr_dq] = proto_estimator_mras_vehicle( ...
    id_meas, iq_meas, vd_cmd, vq_cmd, vdc_meas, theta_e, omega_e, mode, cfg) %#codegen
%PROTO_ESTIMATOR_MRAS_VEHICLE MRAS parameter estimator for high-speed PMSM EV drive
%
% Paper: A. Flah, M. Novak, L. Sbita, J. Novak, "Estimation of motor parameters for an
% electrical vehicle application", Int. J. Modelling, Identification and Control, vol. 22,
% no. 2, 2014, pp. 150-158.
%
% Implementation notes (mapping to paper):
%   - Eq. (5)-(6): adjustable model integrates estimated currents using estimated Rs, Ls, λ.
%   - Eq. (7): residuals between measured and adjustable-model currents -> e_id, e_iq.
%   - Eq. (8)-(9): PI-style adaptation on Rs, Ls, λ implemented as discrete integrators with
%     proportional action driven by tailored residual combinations (currents, voltages, ω).
%   - High-speed operation handled via mode-aware gain scaling (PWM vs WF) per §3 discussion.
%
% Inputs follow AGENTS.md §4.1. Outputs expose parameter estimates and diagnostics.
%
% cfg fields used:
%   Ts_ctrl, reset_flag, p
%   Rs_nom, Rs_minmax, Ls_nom, Ls_minmax, lambda_nom, lambda_minmax
%   gains: struct with Rs_kp, Rs_ki, Ls_kp, Ls_ki, Flux_kp, Flux_ki, Ls_eps
%   model_blend, mode_gain_pwm, mode_gain_wf, omega_min_adapt
%   sat.vdq_max
%
% diag struct includes residuals, adaptation signals, gain scale, saturation flags, timestamp.

% Guard configuration
if ~isfield(cfg, 'Ts_ctrl')
    error('cfg.Ts_ctrl missing');
end
Ts = cfg.Ts_ctrl;
if Ts <= 0
    error('cfg.Ts_ctrl must be positive');
end

% Saturate commanded voltages for numerical safety
vd = clamp_scalar(vd_cmd, -cfg.sat.vdq_max, cfg.sat.vdq_max);
vq = clamp_scalar(vq_cmd, -cfg.sat.vdq_max, cfg.sat.vdq_max);

% Persistent states per AGENTS.md
persistent Rs_hat Ls_hat lambda_hat id_hat iq_hat int_R int_L int_F
persistent id_prev iq_prev time_accum last_mode
if isempty(Rs_hat) || cfg.reset_flag
    Rs_hat = cfg.Rs_nom;
    Ls_hat = cfg.Ls_nom;
    lambda_hat = cfg.lambda_nom;
    id_hat = cfg.init.id0;
    iq_hat = cfg.init.iq0;
    int_R = 0.0;
    int_L = 0.0;
    int_F = 0.0;
    id_prev = id_meas;
    iq_prev = iq_meas;
    time_accum = 0.0;
    last_mode = mode;
end

% Time accumulation
time_accum = time_accum + Ts;
last_mode = mode;

% Estimated model integration (Euler + measurement blending for stability)
omega = omega_e;
Ls_eff = max(Ls_hat, cfg.gains.Ls_eps);

% Predict adjustable-model currents with present parameter estimates
id_dot_hat = (vd - Rs_hat * id_hat + omega * Ls_hat * iq_hat) / Ls_eff;
iq_dot_hat = (vq - Rs_hat * iq_hat - omega * (Ls_hat * id_hat + lambda_hat)) / Ls_eff;
blend = cfg.model_blend;
id_hat = id_hat + Ts * id_dot_hat + blend * (id_meas - id_hat);
iq_hat = iq_hat + Ts * iq_dot_hat + blend * (iq_meas - iq_hat);

% Current residuals (Eq. 7)
e_id = id_meas - id_hat;
e_iq = iq_meas - iq_hat;

% Measured current derivatives for voltage residuals
id_der = (id_meas - id_prev) / Ts;
iq_der = (iq_meas - iq_prev) / Ts;
id_prev = id_meas;
iq_prev = iq_meas;

% Reference model voltages reconstructed from measured currents and estimates
vd_model = Rs_hat * id_meas + Ls_hat * id_der - omega * Ls_hat * iq_meas;
vq_model = Rs_hat * iq_meas + Ls_hat * iq_der + omega * (Ls_hat * id_meas + lambda_hat);
vd_res = vd - vd_model;
vq_res = vq - vq_model;

% Mode-aware adaptation scaling
if mode == uint8(0)
    adapt_scale = cfg.mode_gain_pwm;
else
    adapt_scale = cfg.mode_gain_wf;
end
if abs(omega) < cfg.omega_min_adapt
    adapt_scale = adapt_scale * (abs(omega) / cfg.omega_min_adapt);
end
adapt_scale = clamp_scalar(adapt_scale, 0.0, 1.0);

% Adaptation signals (heuristic mapping of Eq. 9 terms)
phi_R = e_id * id_meas + e_iq * iq_meas;
phi_L = vd_res * id_meas + vq_res * iq_meas;
phi_F = e_iq * omega;
phi_R = adapt_scale * phi_R;
phi_L = adapt_scale * phi_L;
phi_F = adapt_scale * phi_F;

% PI adaptation with simple anti-windup (sat-based back-calculation)
% Resistance
int_R = int_R + cfg.gains.Rs_ki * phi_R * Ts;
Rs_trial = cfg.Rs_nom + cfg.gains.Rs_kp * phi_R + int_R;
[Rs_hat, int_R, sat_R] = apply_sat_with_backcalc(Rs_trial, cfg.Rs_minmax(1), cfg.Rs_minmax(2), ...
    cfg.Rs_nom, cfg.gains.Rs_kp, phi_R, int_R);

% Inductance
int_L = int_L + cfg.gains.Ls_ki * phi_L * Ts;
Ls_trial = cfg.Ls_nom + cfg.gains.Ls_kp * phi_L + int_L;
[Ls_hat, int_L, sat_L] = apply_sat_with_backcalc(Ls_trial, cfg.Ls_minmax(1), cfg.Ls_minmax(2), ...
    cfg.Ls_nom, cfg.gains.Ls_kp, phi_L, int_L);
Ls_hat = max(Ls_hat, cfg.gains.Ls_eps);

% Flux linkage
int_F = int_F + cfg.gains.Flux_ki * phi_F * Ts;
lambda_trial = cfg.lambda_nom + cfg.gains.Flux_kp * phi_F + int_F;
[lambda_hat, int_F, sat_F] = apply_sat_with_backcalc(lambda_trial, cfg.lambda_minmax(1), cfg.lambda_minmax(2), ...
    cfg.lambda_nom, cfg.gains.Flux_kp, phi_F, int_F);

% Estimated electromagnetic torque using measured iq (surface PMSM)
te_hat = 1.5 * cfg.p * lambda_hat * iq_meas;

% Outputs
state_hat = struct('id_hat', id_hat, ...
                   'iq_hat', iq_hat, ...
                   'Rs_hat', Rs_hat, ...
                   'Ls_hat', Ls_hat, ...
                   'lambda_hat', lambda_hat, ...
                   'te_hat', te_hat);

sat_flags = uint8(0);
if sat_R
    sat_flags = bitor(sat_flags, uint8(1));
end
if sat_L
    sat_flags = bitor(sat_flags, uint8(2));
end
if sat_F
    sat_flags = bitor(sat_flags, uint8(4));
end

diag = struct('res_i', [e_id; e_iq], ...
              'res_v', [vd_res; vq_res], ...
              'phi', [phi_R; phi_L; phi_F], ...
              'mode', mode, ...
              'adapt_scale', adapt_scale, ...
              'sat_flags', sat_flags, ...
              'time_s', time_accum, ...
              'theta_e', theta_e, ...
              'vdc', vdc_meas, ...
              'gains', [cfg.gains.Rs_kp; cfg.gains.Rs_ki; cfg.gains.Ls_kp; cfg.gains.Ls_ki; cfg.gains.Flux_kp; cfg.gains.Flux_ki], ...
              'events', uint8(0));

v_corr_dq = [0.0; 0.0]; %#ok<NASGU>

end

function y = clamp_scalar(x, xmin, xmax)
if x < xmin
    y = xmin;
elseif x > xmax
    y = xmax;
else
    y = x;
end
end

function [x_sat, int_state, hit] = apply_sat_with_backcalc(x_trial, xmin, xmax, x_nom, kp, phi, int_state)
hit = false;
x_sat = x_trial;
if x_trial < xmin
    x_sat = xmin;
    hit = true;
elseif x_trial > xmax
    x_sat = xmax;
    hit = true;
end
if hit
    int_state = x_sat - x_nom - kp * phi;
end
end
