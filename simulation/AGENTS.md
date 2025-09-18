# AGENT.md — Motor Control Prototyping Spec (MATLAB/Simulink, IPMSM)

> Purpose: Enable an AI agent to implement **paper‑based motor‑control prototypes** as MATLAB Function blocks that plug into your existing Simulink environment (Controller + Inverter + Motor). This file defines scope, interfaces, signals, assumptions, coding conventions, and acceptance criteria so prototypes are drop‑in and testable.

---

## 0. Quick Summary (TL;DR for the Agent)

* **Plant**: 3‑phase inverter (dead‑time modeled) + measured‑map IPMSM (≈150 kW) in Simulink.
* **Control**: MTPA **(PWM)** and WF/6‑step **(commutation @ 60°)**, auto‑switched by modulation index.
* **I/O available**: phase currents (Ia, Ib, Ic + Id/Iq), electrical angle θe from sensor, DC‑link voltage, inverter command voltages, speed derived from θe (no closed‑loop speed control).
* **What to build**: MATLAB Function blocks that implement the target paper’s algorithm (observer/estimator/compensator/torque/power logic, etc.).
* **How to wire**: Strict I/O schema (below), fixed units, sample‑time, robust to PWM vs WF modes, dead‑time aware options.
* **Done when**: The block compiles, runs in the provided harness, logs defined KPIs, passes acceptance tests & scenarios.

---

## 1. Scope & Goals

* Implement **algorithm prototypes** described in research papers (e.g., observers, estimators, compensators, HF‑injection demod, power/torque estimators).
* Deliver **single or small set of MATLAB Function blocks** that integrate without rewiring the plant.
* Support **both modulation regimes** (PWM/MTPA and WF/6‑step) and transitions.
* Provide **diagnostic outputs and reproducible tests**.

### Out‑of‑Scope

* Replacing the user’s controller design.
* Changing motor or inverter parameterization beyond block configuration structs.

---

## 2. Simulation Environment (Given)

### 2.1 Plant Overview

* **Inverter model**: 3‑phase bridge with explicit dead‑time.

  * Key parameter: `deadtime_us` (typical 0.3–1.0 µs).
  * RLC parasitics set to plausible constants (rarely changed).
* **Motor model**: IPMSM (≈150 kW) with **measured flux map** implementation.

  * Maps available: Φd, Φq, ∂Φ/∂i (Ld\_map, Lq\_map), possibly Hessians.
* **No speed loop**: Rotor speed is not controlled; θe measured, ωe computed from Δθ/Δt.

### 2.2 Controller Overview

* **Inputs**: phase currents or Id/Iq, electrical angle θe, DC‑bus voltage Vdc.
* **Outputs**:

  * **MTPA (PWM)** → 3‑phase duty commands (mod index‑based).
  * **WF/6‑step** → 3‑phase 180° conduction, commutation every 60° (angle‑aligned).
* **Mode switching**: Based on modulation index (threshold provided via config).

---

## 3. Signals, Units, Rates

* **Electrical angle θe**: \[rad], continuous 0…2π wrap; monotonic across wrap.
* **Electrical speed ωe**: \[rad/s], derived from θe via discrete diff + filtering.
* **Currents**: Ia, Ib, Ic \[A]; Id, Iq \[A] (Park transform). Sign convention: dq aligned with θe.
* **Voltages**: Vdc \[V], Vαβ, Vdq \[V]. Commanded vs. estimated should be distinguishable.
* **Torque**: Te \[N·m] (plant truth available), T̂e \[N·m] (estimator output when applicable).
* **Sample time**: control period `Ts_ctrl` (e.g., 50–200 µs). If using carrier‑synchronous functions, note PWM half‑carrier `Ts_pwm/2`.
* **Coordinate transforms**: Clarke/Park as per standard (αβ→dq with θe). Provide helper if needed.

---

## 4. Block Interfaces (Strict I/O Schema)

The AI must implement MATLAB Function blocks with the following **canonical signatures** so they’re plug‑and‑play. Each prototype should pick the closest matching interface; add fields only via config structs.

### 4.1 Estimator / Observer Block (generic)

**Block name**: `proto_estimator_<paper_key>`

**Inputs** (scalar unless noted):

* `id_meas, iq_meas` \[A]
* `vd_cmd, vq_cmd` \[V] — controller’s dq command (pre‑modulation) if available; else use measured Vαβ→dq.
* `vdc_meas` \[V]
* `theta_e` \[rad]
* `omega_e` \[rad/s]
* `mode` \[uint8] — 0: PWM/MTPA, 1: WF/6‑step
* `cfg` (struct) — parameters (see §5)

**Outputs**:

* `state_hat` (struct) — fields depend on paper (e.g., `phi_d_hat, phi_q_hat, rs_hat, te_hat`)
* `diag` (struct) — residuals, gains, flags (e.g., `r_id, r_iq, sat_flags, kf_diag`)
* `v_corr_dq` \[V 2×1] (optional) — voltage correction to mitigate dead‑time or sensor bias

**Function header example**:

```matlab
function [state_hat, diag, v_corr_dq] = proto_estimator_paperX( ...
    id_meas, iq_meas, vd_cmd, vq_cmd, vdc_meas, theta_e, omega_e, mode, cfg)
```

### 4.2 HF Injection + Demod (if relevant)

**Block name**: `proto_hfi_demod_<paper_key>`

**Inputs**: `id_meas, iq_meas, theta_e, vdc_meas, cfg`

**Outputs**: `demod_sig` (struct with in‑phase/quadrature), `theta_obs` (optional), `flags`

### 4.3 Power/Torque Estimator

**Block name**: `proto_power_torque_<paper_key>`

**Inputs**: `vd_cmd, vq_cmd, id_meas, iq_meas, vdc_meas, cfg`

**Outputs**: `p_est` \[W], `te_est` \[N·m], `loss_est` (struct), `diag`

---

## 5. Configuration Structs & Parameters

All tunables go into `cfg` to avoid changing ports.

```matlab
% cfg (example fields; extend per paper)
cfg.Ts_ctrl          % [s] control step
cfg.deadtime_us      % [us] inverter dead‑time (inform models/compensation)
cfg.mode_thresh_mi   % [–] modulation index threshold (PWM↔WF)

% Sensor models / filters
cfg.theta_wrap       % logical, enable wrap‑safe diff
cfg.omega_lp_tau     % [s] speed LPF time constant

% Motor params (nominal)
cfg.p                % pole pairs
cfg.Rs_nom           % [ohm]
cfg.Rs_minmax        % [ohm 1×2] bounds for estimation

% Flux maps / LUT handles
cfg.map_phi_d        % function handle: [phi_d] = map_phi_d(id,iq)
cfg.map_phi_q
cfg.map_Ld, cfg.map_Lq
cfg.map_Hd, cfg.map_Hq   % optional Hessians

% HFI (if used)
cfg.hf.freq          % [Hz]
cfg.hf.amp_dq        % [V 1×2]
cfg.hf.toggle_per    % [s] 90° toggling interval (carrier‑aware)

% Estimator / EKF settings
cfg.kf.Q, cfg.kf.R   % covariance
cfg.kf.P0            % init covariance
cfg.sat.vdq_max      % [V] saturation for numerical safety
```

> **Note**: When paper demands explicit dead‑time modeling, either (a) request inverter’s internal estimate of effective VDQ, or (b) pass a `deadtime_comp(vdq_cmd, i_sign, vdc)` helper toggled by `cfg.enable_dt_comp`.

---

## 6. Coding Conventions (MATLAB Function)

* **Deterministic state**: Use `persistent` for states; expose init/reset via `cfg.reset_flag`.
* **Wrap‑safe math**: normalize angles to \[0, 2π) and provide `unwrap_discrete` for ωe.
* **Numerical hygiene**: saturate inputs/outputs, guard divisions (`eps`), Joseph form for covariance updates in EKF/UKF.
* **Allocations**: no dynamic allocations in the step; pre‑size structs.
* **Transforms**: include local `clarke/park/invpark` helpers if not provided.
* **Mode‑aware**: branch lightweight behaviors for PWM vs WF to avoid aliasing (e.g., demod windows aligned to conduction pattern).

---

## 7. Test Harness & Log Signals

### 7.1 Test Scenarios (minimum)

1. **Steady PWM / MTPA**: fixed torque command, mid DC bus.
2. **WF/6‑step**: high modulation, commutation at 60°; check robustness.
3. **Mode transition**: ramp command across modulation threshold.
4. **Dead‑time sweep**: vary `deadtime_us` within spec.
5. **Speed profile**: step/ramp in ωe via θe source (no speed loop).
6. **Sensor perturbations**: Vdc bias, current noise.

### 7.2 KPIs / Acceptance Criteria

* **Convergence** of estimator states (e.g., ||Δφ̂|| → small, Rŝ within bounds).
* **Torque tracking**: |Te − T̂e| RMS below threshold over window.
* **Power balance**: P̂conv ≈ V·I within tolerance accounting for copper/iron/inverter losses model.
* **Robustness**: No instability during PWM↔WF transitions; bounded residuals under dead‑time variation.
* **Runtime**: ≤ control step budget (report avg/max step time).

### 7.3 Logging Contract

Agent must expose a `diag` struct with at least: timestamps, residuals, gains, saturations, mode, and any detected events (e.g., wrap, reset, commutation edges).

---

## 8. Integration Checklist (for each prototype)

* [ ] Block uses the **canonical signature**.
* [ ] `cfg` contains **all tunables**; defaults provided.
* [ ] Units match (§3) and angles wrap‑safe.
* [ ] Handles PWM & WF and transition.
* [ ] Dead‑time strategy documented (ignore / estimate / compensate).
* [ ] Test scenarios executed; KPIs reported.
* [ ] README section in code header with paper citation + mapping of equations→implementation.

---

## 9. Example: MATLAB Function Skeleton (EKF‑style Estimator)

```matlab
function [state_hat, diag, v_corr_dq] = proto_estimator_paperX( ...
    id_meas, iq_meas, vd_cmd, vq_cmd, vdc_meas, theta_e, omega_e, mode, cfg)
%#codegen

% ── persistent state ────────────────────────────────────────────
persistent x P
if isempty(x)
    x = [0;0; cfg.Rs_nom];       % e.g., [Δφd; Δφq; Rs]
    P = diag([1e-3,1e-3, (0.1*cfg.Rs_nom)^2]);
end

Ts = cfg.Ts_ctrl;

% ── preprocess ─────────────────────────────────────────────────
[theta_e] = wrap2pi(theta_e);

% Saturate command voltages (optional)
vd = max(min(vd_cmd, cfg.sat.vdq_max), -cfg.sat.vdq_max);
vq = max(min(vq_cmd, cfg.sat.vdq_max), -cfg.sat.vdq_max);

% ── model & Jacobians (paper‑specific; placeholders) ───────────
% x = [Δφd; Δφq; Rs]
% f(x,u): flux deviation dynamics, Rs random walk
A = eye(3);              % placeholder
Q = cfg.kf.Q;            % 3x3
H = [1 0 0; 0 1 0];      % measure Δφ via current residual model (example)
R = cfg.kf.R;            % 2x2

% ── predict ────────────────────────────────────────────────────
x_pred = A * x;          % + B*u if needed
P_pred = A * P * A.' + Q;

% Innovation from measured currents via map (example)
[phi_d0, phi_q0] = map_phi(cfg, id_meas, iq_meas);
phi_d_hat = phi_d0 + x_pred(1);
phi_q_hat = phi_q0 + x_pred(2);

z = [phi_d_hat; phi_q_hat];      % synthetic measurement example
z_meas = flux_from_i_v(cfg, id_meas, iq_meas, vd, vq, omega_e, x_pred(3), Ts); % paper‑specific

r = z_meas - z;
S = H * P_pred * H.' + R;
K = (P_pred * H.') / S;

x = x_pred + K * r;
I_KH = eye(3) - K*H;
P = I_KH * P_pred * I_KH.' + K * R * K.';  % Joseph form

% ── outputs ────────────────────────────────────────────────────
state_hat.phi_d = phi_d0 + x(1);
state_hat.phi_q = phi_q0 + x(2);
state_hat.Rs    = x(3);

v_corr_dq = [0;0];   % optional dead‑time/sensor correction output

% diag/logging
diag.r = r; diag.S = S; diag.K = K; diag.mode = mode;
```

Helper stubs to add below the function:

```matlab
function [phi_d0, phi_q0] = map_phi(cfg, id, iq)
phi_d0 = cfg.map_phi_d(id,iq);
phi_q0 = cfg.map_phi_q(id,iq);
end

function y = wrap2pi(x)
y = x - 2*pi*floor(x/(2*pi));
end
```

---

## 10. Prompts the Agent Understands (Task Contract)

When requesting a prototype, use this **prompt template** in your issue/chat:

**Title**: Implement <PaperShortName> estimator as MATLAB Function block

**Context**:

* Plant: inverter(dead‑time = <value> µs), IPMSM 150 kW, flux map available.
* Control: MTPA(PWM) & WF(6‑step), switching by modulation index.
* Available signals: Id/Iq, θe, ωe (derived), Vdc, Vdq\_cmd, plant Te.
* Constraints: keep I/O schema per AGENT.md §4, use Joseph form for covariance, wrap‑safe angles.

**Deliverables**:

* `proto_estimator_<paper_key>.m` with header docs mapping paper eqs→code lines.
* `cfg_<paper_key>.m` default config.
* Short test harness script + scope signals + KPI printout.

**Acceptance**:

* Runs in 6 scenarios (§7.1) with KPIs within thresholds (§7.2). No NaNs, no rate overruns.

---

## 11. Versioning & Review

* Every prototype includes a **header** with paper citation (title, authors, year), assumed equations, and deviations.
* Use semantic suffixes: `proto_estimator_<paperkey>_v1.m` if breaking changes.
* Commit message checklist mirrors §8.

---

## 12. Known Pitfalls & Guidance

* **Dead‑time effects**: command Vdq ≠ effective Vdq; either estimate effective voltage or compensate.
* **PWM→WF transition**: estimator windows must avoid commutation edge transients (align demod windows if HFI).
* **Map extrapolation**: clamp Id/Iq to map bounds; log saturations.
* **Angle unwrap**: ωe spikes from wraps—always wrap‑safe diff.
* **Numerical stiffness**: prefer simple discrete models first; add complexity once stable.

---

## 13. Appendix — Example Config Defaults

```matlab
cfg = struct();
cfg.Ts_ctrl = 1/20000;     % 50 µs
cfg.deadtime_us = 0.6;
cfg.mode_thresh_mi = 0.95;

cfg.theta_wrap = true;
cfg.omega_lp_tau = 0.002;

cfg.p = 4;
cfg.Rs_nom = 0.037;
cfg.Rs_minmax = [0.7, 1.3]*cfg.Rs_nom;

cfg.sat.vdq_max = 600;

cfg.kf = struct();
cfg.kf.Q = diag([1e-6, 1e-6, 1e-8]);
cfg.kf.R = diag([1e-4, 1e-4]);
cfg.kf.P0 = diag([1e-3, 1e-3, (0.1*cfg.Rs_nom)^2]);

% Placeholders for map handles (user must bind real ones)
cfg.map_phi_d = @(id,iq) 0.0*id + 0.0*iq;
cfg.map_phi_q = @(id,iq) 0.0*id + 0.0*iq;
```
