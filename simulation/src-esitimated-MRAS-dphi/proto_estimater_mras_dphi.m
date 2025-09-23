function [id_hat, iq_hat, Rs_hat, Ld_hat, Lq_hat, lam_hat] = ...
    mras_pmsm_dphi_step(id, iq, vd, vq, omega)
%==========================================================================
% MRAS-based PMSM Parameter Estimator (dq) + Δφ model (d-axis)
%   - Adjustable model with output-error injection G
%   - PI adaptation of θ = {Rs, Ld, Lq, λm}
%   - Δφ_d(i,ω) ≈ sum_j alpha(j)*varphi_j(i_d_hat, i_q_hat, ω)
%   - Optional: normalization of regressors, leakage regularization
%
% Inputs : id, iq [A], vd, vq [V], omega [rad/s] (electrical)
% Outputs: id_hat, iq_hat [A], Rs_hat [Ω], Ld_hat, Lq_hat [H], lam_hat [Wb]
%==========================================================================

% ── User tuning (必要に応じてマスク引数化) ──────────────────────────────
Ts = 100e-6;            % sample time
USE_NORM_PHI = true;    % normalize regressors (recommended)
EPS_NORM     = 1e-9;

% Error injection (stabilization) G = diag(k1,k2)
k1 = 800; 
k2 = 800;

% PI gains for physical params
kRp = 5e-3;  kRi = 1e-3;    % Rs
kLp = 5e-5;  kLi = 1e-5;    % Ld, Lq
kPp = 5e-4;  kPi = 1e-4;    % lam

% Nameplate / initial guesses
Rs_nom  = 0.20;            % [Ω]
Ld_nom  = 1.10e-3;         % [H]
Lq_nom  = 1.30e-3;         % [H]
lam_nom = 0.070;           % [Wb]

% Physical clamps
Rs_min = 0.5*Rs_nom; Rs_max = 1.5*Rs_nom;
Ld_min = 0.5*Ld_nom; Ld_max = 1.8*Ld_nom;
Lq_min = 0.5*Lq_nom; Lq_max = 1.8*Lq_nom;
lam_min = 0.5*lam_nom; lam_max = 1.2*lam_nom;

% ── Δφ_d basis & adaptation settings ─────────────────────────────────────
% Basis size (start small: M=1→2→3...)
M = 3;  % varphi = [1, id_hat, id_hat^3] as an example
% PI gains for alpha (small!)
Kp_alpha = 1e-5*ones(M,1);
Ki_alpha = 1e-6*ones(M,1);
% Leakage (L2 regularization) to avoid drift
leak_alpha = 1e-4*ones(M,1);
% Clamp of each alpha (roughly ±0.02 Wb equivalent bias as a start)
alpha_min = -0.02*ones(M,1);
alpha_max = +0.02*ones(M,1);

% ── States ───────────────────────────────────────────────────────────────
persistent xhat Rs Ld Lq lam zR zLd zLq zLam alpha zAlpha
if isempty(xhat)
    xhat = [0; 0];
    Rs   = Rs_nom; 
    Ld   = Ld_nom; 
    Lq   = Lq_nom; 
    lam  = lam_nom;
    zR   = 0; zLd  = 0; zLq  = 0; zLam = 0;
    alpha   = zeros(M,1);
    zAlpha  = zeros(M,1);
end

% ── Short-hands ──────────────────────────────────────────────────────────
X = [id; iq];
G = diag([k1, k2]);

% ── Adjustable model with Δφ_d(i_d_hat, i_q_hat, ω) ======================
id_hat = xhat(1); iq_hat = xhat(2);

% Δφ_d basis (customize here if needed)
phi_d = basis_d(id_hat, iq_hat, omega, M);   % Mx1
if USE_NORM_PHI
    nrm = norm(phi_d); if nrm < EPS_NORM, nrm = 1; end
    phi_d = phi_d / nrm;
end
dphi_d = alpha.' * phi_d;                     % Δφ_d = Σ αj φj

% dq currents dynamics with Δφ_d
% di_d/dt = (vd - Rs*id_hat + ω*(Lq*iq_hat /* + Δφ_q */ ))/Ld
% di_q/dt = (vq - Rs*iq_hat - ω*(Ld*id_hat + lam + Δφ_d))/Lq
di_d = (vd - Rs*id_hat + omega*(Lq*iq_hat           )) / Ld;
di_q = (vq - Rs*iq_hat - omega*(Ld*id_hat + lam + dphi_d)) / Lq;

% Adjustable model integration + error injection
xhat = xhat + Ts*[di_d; di_q] + Ts*G*(xhat - X);
id_hat = xhat(1); iq_hat = xhat(2);

% ── Error ────────────────────────────────────────────────────────────────
e = xhat - X;   % e = [e_d; e_q]

% ── Regressors (physical params) =========================================
% φ_Rs = [-id/Ld; -iq/Lq]
phi_Rs  = [ -id/Ld ; -iq/Lq ];
% φ_Ld = [-(vd - Rs*id + ω*Lq*iq)/Ld^2 ; -(ω*id)/Lq]
vd_drop = vd - Rs*id + omega*Lq*iq;
phi_Ld  = [ -vd_drop/(Ld^2) ; -(omega*id)/Lq ];
% φ_Lq = [ (ω*iq)/Ld ; -(vq - Rs*iq - ω*(Ld*id + lam))/Lq^2 ]
vq_drop = vq - Rs*iq - omega*(Ld*id + lam);
phi_Lq  = [  (omega*iq)/Ld ; -vq_drop/(Lq^2) ];
% φ_λ  = [0 ; -ω/Lq]
phi_lam = [ 0 ; -omega/Lq ];

if USE_NORM_PHI
    phi_Rs  = phi_Rs  / (norm(phi_Rs ) + EPS_NORM);
    phi_Ld  = phi_Ld  / (norm(phi_Ld ) + EPS_NORM);
    phi_Lq  = phi_Lq  / (norm(phi_Lq ) + EPS_NORM);
    phi_lam = phi_lam / (norm(phi_lam) + EPS_NORM);
end

% ── PI adaptation (physical params) ======================================
eps_R   = phi_Rs.'  * e;
eps_Ld  = phi_Ld.'  * e;
eps_Lq  = phi_Lq.'  * e;
eps_lam = phi_lam.' * e;

zR   = zR   + Ts*eps_R;
zLd  = zLd  + Ts*eps_Ld;
zLq  = zLq  + Ts*eps_Lq;
zLam = zLam + Ts*eps_lam;

Rs_new  = Rs  + (kRp*eps_R   + kRi*zR);
Ld_new  = Ld  + (kLp*eps_Ld  + kLi*zLd);
Lq_new  = Lq  + (kLp*eps_Lq  + kLi*zLq);
lam_new = lam + (kPp*eps_lam + kPi*zLam);

[Rs,  cRs]  = clamp(Rs_new,  Rs_min,  Rs_max);
[Ld,  cLd]  = clamp(Ld_new,  Ld_min,  Ld_max);
[Lq,  cLq]  = clamp(Lq_new,  Lq_min,  Lq_max);
[lam, clam] = clamp(lam_new, lam_min, lam_max);

if cRs,  zR   = zR   - (Rs_new  - Rs ) * safe_inv(kRi);  end
if cLd,  zLd  = zLd  - (Ld_new  - Ld ) * safe_inv(kLi);  end
if cLq,  zLq  = zLq  - (Lq_new  - Lq ) * safe_inv(kLi);  end
if clam, zLam = zLam - (lam_new - lam) * safe_inv(kPi);  end

% ── PI adaptation (Δφ_d coefficients alpha) ===============================
% Sensitivity: ∂(di_q/dt)/∂alpha_j = -(ω/Lq)*varphi_j  → φ_αj = [0 ; -(ω/Lq)*varphi_j]
% ⇒ ε_α = φ_α^T e = -(ω/Lq)*(varphi_j * e_q)  (vectorized)
eps_alpha = -(omega/Lq) * (phi_d * e(2));     % Mx1
zAlpha    = zAlpha + Ts*eps_alpha;
alpha_new = alpha + Kp_alpha.*eps_alpha + Ki_alpha.*zAlpha - leak_alpha.*alpha;

% Clamp alphas
alpha = min(max(alpha_new, alpha_min), alpha_max);

% ── Outputs ──────────────────────────────────────────────────────────────
id_hat  = xhat(1);
iq_hat  = xhat(2);
Rs_hat  = Rs;
Ld_hat  = Ld;
Lq_hat  = Lq;
lam_hat = lam;

%==========================================================================
% Local functions
%==========================================================================
function ph = basis_d(idh, iqh, omg, M_)
    %#ok<INUSD> % default example basis (edit freely)
    switch M_
        case 1
            ph = [1];                                   % constant bias
        case 2
            ph = [1; idh];                              % add linear id term
        otherwise
            ph = [1; idh; idh^3];                       % add cubic id term
            % e.g., for richer basis:
            % ph = [1; idh; idh^3; iqh^2*idh];
    end
end

function [y, clamped] = clamp(xv, xmin, xmax)
    if xv < xmin
        y = xmin; clamped = true;
    elseif xv > xmax
        y = xmax; clamped = true;
    else
        y = xv;   clamped = false;
    end
end

function invg = safe_inv(k)
    tiny = 1e-12;
    invg = 1.0 / max(k, tiny);
end

end
