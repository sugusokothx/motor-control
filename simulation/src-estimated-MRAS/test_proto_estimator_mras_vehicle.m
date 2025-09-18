function test_proto_estimator_mras_vehicle()
%TEST_PROTO_ESTIMATOR_MRAS_VEHICLE Basic self-test for proto_estimator_mras_vehicle.
%
% Simulates a representative high-speed operating point with known PMSM parameters
% and feeds synthetic measurements into the estimator. Prints convergence report for
% Rs, Ls, and lambda_m.

cfg = cfg_estimator_mras_vehicle();
cfg.reset_flag = true;

% True plant parameters (perturbed from defaults)
Rs_true = 0.245;          % ohm
Ls_true = 1.25e-3;        % H
lambda_true = 0.069;      % Wb

Ts = cfg.Ts_ctrl;
N = 4000;                 % 0.2 s simulation

% Operating profiles
id_profile = -15 * ones(1, N);
iq_profile = 45 * ones(1, N);
omega_profile = linspace(400, 1200, N);   % rad/s sweep (~3.8k to 11.5k rpm)
mode_profile = uint8(zeros(1, N));
mode_profile(ceil(0.6*N):end) = uint8(1);

theta = 0.0;

Rs_est = zeros(1, N);
Ls_est = zeros(1, N);
lam_est = zeros(1, N);
scale_log = zeros(1, N);

for k = 1:N
    id = id_profile(k);
    iq = iq_profile(k);
    omega = omega_profile(k);
    theta = theta + omega * Ts;
    theta = mod(theta, 2*pi);

    % Currents held near constant -> derivatives ≈ 0
    did = 0.0;
    diq = 0.0;

    vd = Rs_true * id + Ls_true * did - omega * Ls_true * iq;
    vq = Rs_true * iq + Ls_true * diq + omega * (Ls_true * id + lambda_true);

    cfg.reset_flag = (k == 1);  % pulse reset on first call
    [state_hat, diag] = proto_estimator_mras_vehicle(id, iq, vd, vq, 560.0, theta, omega, mode_profile(k), cfg);
    cfg.reset_flag = false;

    Rs_est(k) = state_hat.Rs_hat;
    Ls_est(k) = state_hat.Ls_hat;
    lam_est(k) = state_hat.lambda_hat;
    scale_log(k) = diag.adapt_scale;
end

fprintf('Final estimates after %.3f s:\n', N * Ts);
fprintf('  Rs_hat     = %.4f ohm (true %.4f)\n', Rs_est(end), Rs_true);
fprintf('  Ls_hat     = %.4e H   (true %.4e)\n', Ls_est(end), Ls_true);
fprintf('  lambda_hat = %.4f Wb  (true %.4f)\n', lam_est(end), lambda_true);

settle_idx = round(0.8 * N);
fprintf('\nAverages over last 20%% samples:\n');
fprintf('  Rs_hat avg     = %.4f ohm\n', mean(Rs_est(settle_idx:end)));
fprintf('  Ls_hat avg     = %.4e H\n', mean(Ls_est(settle_idx:end)));
fprintf('  lambda_hat avg = %.4f Wb\n', mean(lam_est(settle_idx:end)));

fprintf('\nAdaptation scale min/max: [%.2f, %.2f]\n', min(scale_log), max(scale_log));

end
