function test_proto_estimator_mras_vehicle_ldlq()
%TEST_PROTO_ESTIMATOR_MRAS_VEHICLE_LDLQ Simple excitation for salient estimator.

cfg = cfg_estimator_mras_vehicle_ldlq();
cfg.reset_flag = true;

Rs_true = 0.240;
Ld_true = 0.80e-3;
Lq_true = 1.40e-3;
lambda_true = 0.068;

Ts = cfg.Ts_ctrl;
N = 6000;  % 0.3 s

t = (0:N-1) * Ts;
id_profile = -20 + 6 * sin(2*pi*150*t);
iq_profile = 45 + 8 * sin(2*pi*220*t + 0.4);
omega_profile = 800 + 300 * sin(2*pi*40*t);
mode_profile = uint8(zeros(1, N));
mode_profile(ceil(0.55*N):end) = uint8(1);

theta = 0.0;

rs_log = zeros(1, N);
ld_log = zeros(1, N);
lq_log = zeros(1, N);
lam_log = zeros(1, N);
scale_log = zeros(1, N);

id_prev = id_profile(1);
iq_prev = iq_profile(1);

for k = 1:N
    id = id_profile(k);
    iq = iq_profile(k);
    omega = omega_profile(k);
    theta = theta + omega * Ts;
    theta = mod(theta, 2*pi);

    if k == 1
        id_der = 0.0;
        iq_der = 0.0;
    else
        id_der = (id - id_prev) / Ts;
        iq_der = (iq - iq_prev) / Ts;
    end
    id_prev = id;
    iq_prev = iq;

    vd = Rs_true * id + Ld_true * id_der - omega * Lq_true * iq;
    vq = Rs_true * iq + Lq_true * iq_der + omega * (Ld_true * id + lambda_true);

    cfg.reset_flag = (k == 1);
    [state_hat, diag] = proto_estimator_mras_vehicle_ldlq(id, iq, vd, vq, 560.0, theta, omega, mode_profile(k), cfg);
    cfg.reset_flag = false;

    rs_log(k) = state_hat.Rs_hat;
    ld_log(k) = state_hat.Ld_hat;
    lq_log(k) = state_hat.Lq_hat;
    lam_log(k) = state_hat.lambda_hat;
    scale_log(k) = diag.adapt_scale;
end

fprintf('Final estimates after %.3f s:\n', N * Ts);
fprintf('  Rs_hat     = %.4f ohm (true %.4f)\n', rs_log(end), Rs_true);
fprintf('  Ld_hat     = %.4e H   (true %.4e)\n', ld_log(end), Ld_true);
fprintf('  Lq_hat     = %.4e H   (true %.4e)\n', lq_log(end), Lq_true);
fprintf('  lambda_hat = %.4f Wb  (true %.4f)\n', lam_log(end), lambda_true);

settle_idx = round(0.8 * N);
fprintf('\nAverages over last 20%% samples:\n');
fprintf('  Rs_hat avg = %.4f ohm\n', mean(rs_log(settle_idx:end)));
fprintf('  Ld_hat avg = %.4e H\n', mean(ld_log(settle_idx:end)));
fprintf('  Lq_hat avg = %.4e H\n', mean(lq_log(settle_idx:end)));
fprintf('  lambda_hat avg = %.4f Wb\n', mean(lam_log(settle_idx:end)));

fprintf('\nAdaptation scale min/max: [%.2f, %.2f]\n', min(scale_log), max(scale_log));

end
