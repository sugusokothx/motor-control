function cfg = cfg_estimator_mras_vehicle_ldlq()
%CFG_ESTIMATOR_MRAS_VEHICLE_LDLQ Default settings for salient MRAS estimator.

cfg = struct();

cfg.Ts_ctrl = 5e-5;      % 50 µs
cfg.reset_flag = false;

cfg.p = 4;

cfg.Rs_nom = 0.210;
cfg.Rs_minmax = [0.12, 0.35];

cfg.Ld_nom = 0.9e-3;
cfg.Ld_minmax = [0.5e-3, 1.4e-3];

cfg.Lq_nom = 1.3e-3;
cfg.Lq_minmax = [0.8e-3, 1.8e-3];

cfg.lambda_nom = 0.072;
cfg.lambda_minmax = [0.05, 0.10];

cfg.sat = struct('vdq_max', 600.0);

cfg.gains = struct();
cfg.gains.Rs_kp = 2.0e-3;
cfg.gains.Rs_ki = 30.0;
cfg.gains.Ld_kp = 4.0e-4;
cfg.gains.Ld_ki = 6.0;
cfg.gains.Lq_kp = 4.0e-4;
cfg.gains.Lq_ki = 6.0;
cfg.gains.Flux_kp = 5.0e-4;
cfg.gains.Flux_ki = 2.0;
cfg.gains.Ld_eps = 5.0e-6;
cfg.gains.Lq_eps = 5.0e-6;

cfg.model_blend = 0.05;
cfg.mode_gain_pwm = 1.0;
cfg.mode_gain_wf = 0.4;
cfg.omega_min_adapt = 50.0;

cfg.init = struct('id0', 0.0, 'iq0', 0.0);

end
