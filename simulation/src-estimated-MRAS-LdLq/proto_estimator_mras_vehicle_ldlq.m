function [state_hat, diag, v_corr_dq] = proto_estimator_mras_vehicle_ldlq( ...
    id_meas, iq_meas, vd_cmd, vq_cmd, vdc_meas, theta_e, omega_e, mode, cfg) %#codegen
%PROTO_ESTIMATOR_MRAS_VEHICLE_LDLQ MRAS estimator with saliency (Ld ≠ Lq).
%
% Based on: A. Flah et al., "Estimation of motor parameters for an electrical vehicle
% application", Int. J. Modelling, Identification and Control, vol. 22, no. 2, 2014.
% Extension: allows separate d/q inductance adaptation for salient PMSM/IPMSM.
%
% Mapping:
%   - Adjustable model derives from paper Eq. (5)-(6) with distinct Ld, Lq.
%   - Residuals per Eq. (7) generated from current and reconstructed voltage mismatch.
%   - Adaptation laws emulate Eq. (8)-(9) using discrete PI loops on Rs, Ld, Lq, λm.
%
% Inputs/outputs follow AGENTS.md §4.1 schema.
%
% cfg fields required:
%   Ts_ctrl, reset_flag, p
%   Rs_nom, Rs_minmax
%   Ld_nom, Ld_minmax, Lq_nom, Lq_minmax
%   lambda_nom, lambda_minmax
%   sat.vdq_max
%   gains struct with fields Rs_kp, Rs_ki, Ld_kp, Ld_ki, Lq_kp, Lq_ki, Flux_kp, Flux_ki,
%       Ld_eps, Lq_eps
%   model_blend, mode_gain_pwm, mode_gain_wf, omega_min_adapt
%   init struct with id0, iq0
%
% diag struct logs residuals, adaptation signals, mode, saturation flags, etc.

if ~isfield(cfg, 'Ts_ctrl')
    error('cfg.Ts_ctrl missing');
end
Ts = cfg.Ts_ctrl;
if Ts <= 0
    error('cfg.Ts_ctrl must be positive');
end

vd = clamp_scalar(vd_cmd, -cfg.sat.vdq_max, cfg.sat.vdq_max);
vq = clamp_scalar(vq_cmd, -cfg.sat.vdq_max, cfg.sat.vdq_max);

persistent Rs_hat Ld_hat Lq_hat lambda_hat id_hat iq_hat
persistent int_R int_Ld int_Lq int_F
persistent id_prev iq_prev time_accum last_mode
if isempty(Rs_hat) || cfg.reset_flag
    Rs_hat = cfg.Rs_nom;
    Ld_hat = cfg.Ld_nom;
    Lq_hat = cfg.Lq_nom;
    lambda_hat = cfg.lambda_nom;
    id_hat = cfg.init.id0;
    iq_hat = cfg.init.iq0;
    int_R = 0.0;
    int_Ld = 0.0;
    int_Lq = 0.0;
    int_F = 0.0;
    id_prev = id_meas;
    iq_prev = iq_meas;
    time_accum = 0.0;
    last_mode = mode;
end

time_accum = time_accum + Ts;
last_mode = mode;

omega = omega_e;
Ld_eff = max(Ld_hat, cfg.gains.Ld_eps);
Lq_eff = max(Lq_hat, cfg.gains.Lq_eps);

id_dot_hat = (vd - Rs_hat * id_hat + omega * Lq_hat * iq_hat) / Ld_eff;
iq_dot_hat = (vq - Rs_hat * iq_hat - omega * (Ld_hat * id_hat + lambda_hat)) / Lq_eff;
blend = cfg.model_blend;
id_hat = id_hat + Ts * id_dot_hat + blend * (id_meas - id_hat);
iq_hat = iq_hat + Ts * iq_dot_hat + blend * (iq_meas - iq_hat);

e_id = id_meas - id_hat;
e_iq = iq_meas - iq_hat;

id_der = (id_meas - id_prev) / Ts;
iq_der = (iq_meas - iq_prev) / Ts;
id_prev = id_meas;
iq_prev = iq_meas;

vd_model = Rs_hat * id_meas + Ld_hat * id_der - omega * Lq_hat * iq_meas;
vq_model = Rs_hat * iq_meas + Lq_hat * iq_der + omega * (Ld_hat * id_meas + lambda_hat);
vd_res = vd - vd_model;
vq_res = vq - vq_model;

if mode == uint8(0)
    adapt_scale = cfg.mode_gain_pwm;
else
    adapt_scale = cfg.mode_gain_wf;
end
if abs(omega) < cfg.omega_min_adapt
    adapt_scale = adapt_scale * (abs(omega) / cfg.omega_min_adapt);
end
adapt_scale = clamp_scalar(adapt_scale, 0.0, 1.0);

phi_R = adapt_scale * (e_id * id_meas + e_iq * iq_meas);
phi_Ld = adapt_scale * (vd_res * id_der + vq_res * omega * id_meas);
phi_Lq = adapt_scale * (vd_res * (-omega * iq_meas) + vq_res * iq_der);
phi_F = adapt_scale * (vq_res * omega);

int_R = int_R + cfg.gains.Rs_ki * phi_R * Ts;
Rs_trial = cfg.Rs_nom + cfg.gains.Rs_kp * phi_R + int_R;
[Rs_hat, int_R, sat_R] = apply_sat_with_backcalc(Rs_trial, cfg.Rs_minmax(1), cfg.Rs_minmax(2), ...
    cfg.Rs_nom, cfg.gains.Rs_kp, phi_R, int_R);

int_Ld = int_Ld + cfg.gains.Ld_ki * phi_Ld * Ts;
Ld_trial = cfg.Ld_nom + cfg.gains.Ld_kp * phi_Ld + int_Ld;
[Ld_hat, int_Ld, sat_Ld] = apply_sat_with_backcalc(Ld_trial, cfg.Ld_minmax(1), cfg.Ld_minmax(2), ...
    cfg.Ld_nom, cfg.gains.Ld_kp, phi_Ld, int_Ld);
Ld_hat = max(Ld_hat, cfg.gains.Ld_eps);

int_Lq = int_Lq + cfg.gains.Lq_ki * phi_Lq * Ts;
Lq_trial = cfg.Lq_nom + cfg.gains.Lq_kp * phi_Lq + int_Lq;
[Lq_hat, int_Lq, sat_Lq] = apply_sat_with_backcalc(Lq_trial, cfg.Lq_minmax(1), cfg.Lq_minmax(2), ...
    cfg.Lq_nom, cfg.gains.Lq_kp, phi_Lq, int_Lq);
Lq_hat = max(Lq_hat, cfg.gains.Lq_eps);

int_F = int_F + cfg.gains.Flux_ki * phi_F * Ts;
lambda_trial = cfg.lambda_nom + cfg.gains.Flux_kp * phi_F + int_F;
[lambda_hat, int_F, sat_F] = apply_sat_with_backcalc(lambda_trial, cfg.lambda_minmax(1), cfg.lambda_minmax(2), ...
    cfg.lambda_nom, cfg.gains.Flux_kp, phi_F, int_F);

te_hat = 1.5 * cfg.p * (lambda_hat * iq_meas + (Ld_hat - Lq_hat) * id_meas * iq_meas);

state_hat = struct('id_hat', id_hat, ...
                   'iq_hat', iq_hat, ...
                   'Rs_hat', Rs_hat, ...
                   'Ld_hat', Ld_hat, ...
                   'Lq_hat', Lq_hat, ...
                   'lambda_hat', lambda_hat, ...
                   'te_hat', te_hat);

sat_flags = uint8(0);
if sat_R, sat_flags = bitor(sat_flags, uint8(1)); end
if sat_Ld, sat_flags = bitor(sat_flags, uint8(2)); end
if sat_Lq, sat_flags = bitor(sat_flags, uint8(4)); end
if sat_F, sat_flags = bitor(sat_flags, uint8(8)); end

diag = struct('res_i', [e_id; e_iq], ...
              'res_v', [vd_res; vq_res], ...
              'phi', [phi_R; phi_Ld; phi_Lq; phi_F], ...
              'mode', mode, ...
              'adapt_scale', adapt_scale, ...
              'sat_flags', sat_flags, ...
              'time_s', time_accum, ...
              'theta_e', theta_e, ...
              'vdc', vdc_meas, ...
              'id_der', id_der, ...
              'iq_der', iq_der, ...
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
