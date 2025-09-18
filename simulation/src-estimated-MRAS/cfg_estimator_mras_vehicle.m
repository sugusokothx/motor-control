function cfg = cfg_estimator_mras_vehicle()
%CFG_ESTIMATOR_MRAS_VEHICLE Default configuration for proto_estimator_mras_vehicle.
% Values aligned with Flah et al. (2014) PMSM prototype (Rs=210 mΩ, Ls≈1.1 mH, λm≈0.072 Wb).

cfg = struct();

cfg.Ts_ctrl = 5e-5;              % 50 µs control period
cfg.reset_flag = false;

cfg.p = 4;                       % pole-pairs (prototype high-speed PMSM)

cfg.Rs_nom = 0.210;
cfg.Rs_minmax = [0.12, 0.35];

cfg.Ls_nom = 1.1e-3;
cfg.Ls_minmax = [0.6e-3, 1.6e-3];

cfg.lambda_nom = 0.072;
cfg.lambda_minmax = [0.05, 0.10];

cfg.sat = struct('vdq_max', 600.0);

cfg.gains = struct();
cfg.gains.Rs_kp = 2.0e-3;
cfg.gains.Rs_ki = 30.0;
cfg.gains.Ls_kp = 4.0e-4;
cfg.gains.Ls_ki = 5.0;
cfg.gains.Flux_kp = 5.0e-4;
cfg.gains.Flux_ki = 2.0;
cfg.gains.Ls_eps = 1.0e-5;

cfg.model_blend = 0.05;          % blend factor for current estimate stabilisation
cfg.mode_gain_pwm = 1.0;
cfg.mode_gain_wf = 0.4;
cfg.omega_min_adapt = 50.0;      % rad/s threshold for adaptation fade-in

cfg.init = struct('id0', 0.0, 'iq0', 0.0);

end
