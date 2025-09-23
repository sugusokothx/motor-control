はい、できます。ポイントは**Δφ（磁束偏差）を「係数に対して線形」な形でパラメタライズ**し、MRASの「誤差×回帰量（感度）」で係数をPI更新することです。下に、設計の道筋→数式→実装メモ→最小コード差分、の順でまとめます。

---

# 1) 発想：Δφ を“線形-イン-パラメータ”にする

MRAS は **Popov の枠**で「前向き線形ブロック＋非線形（適応器）」の組を安定化します。適応側は、**推定したい量が係数に対して線形**だと作りやすく・安定にしやすいです。

* 例（最小構成・まずは d 軸だけ）

  $$
  \psi_d = L_d i_d + \lambda_m + \underbrace{\Delta\phi_d(i_d,i_q,\omega)}_{\text{磁束偏差}}
  \quad,\quad
  \psi_q = L_q i_q
  $$

  $$
  \Delta\phi_d(i_d,i_q,\omega) \approx \sum_{j=1}^{M} \alpha_j\,\varphi_j(i_d,i_q,\omega)
  $$

  ここで $\{\alpha_j\}$ は**推定したい新パラメータ**、$\varphi_j$ は既知の**基底関数**（多項式・スプライン・正規化された LUT の局所基底など）。

* 少しリッチにするなら q 軸側にも偏差を入れる：

  $$
  \psi_q = L_q i_q + \Delta\phi_q(i_d,i_q,\omega),\quad
  \Delta\phi_q \approx \sum_{k=1}^{N}\beta_k\,\chi_k(i_d,i_q,\omega)
  $$

  まずは **$\Delta\phi_d$ だけ**から始めるのが安定。

---

# 2) どこに現れる？（dq 方程式内の入り方）

dq 電圧式（標準形）：

$$
\begin{aligned}
v_d &= R_s i_d + L_d \dot i_d - \omega \psi_q,\\
v_q &= R_s i_q + L_q \dot i_q + \omega \psi_d.
\end{aligned}
$$

$\psi_d,\psi_q$ に Δφ を入れて $\dot i_d,\dot i_q$ へ解くと：

$$
\boxed{
\begin{aligned}
\dot i_d &= \frac{1}{L_d}\Big(v_d - R_s i_d + \omega\big(L_q i_q + \Delta\phi_q\big)\Big),\\
\dot i_q &= \frac{1}{L_q}\Big(v_q - R_s i_q - \omega\big(L_d i_d + \lambda_m + \Delta\phi_d\big)\Big).
\end{aligned}}
$$

この形で、**調整（可変）モデル**の右辺に Δφ をそのまま入れます。

---

# 3) MRAS で必要な回帰量（感度）φ：

MRAS の PI 更新は

$$
\varepsilon_\theta = \phi_\theta^\top e,\quad
\dot{\hat\theta}=k_{\theta p}\varepsilon_\theta + k_{\theta i}\!\int\varepsilon_\theta dt
$$

なので、新しい係数 $\alpha_j$ について\*\*$\partial \dot i_{d,q}/\partial \alpha_j$\*\* を求めればよい：

* いま $\Delta\phi_d=\sum \alpha_j\varphi_j$、$\Delta\phi_q=0$ と仮定すると

  $$
  \frac{\partial \dot i_d}{\partial \alpha_j}=0,\qquad
  \frac{\partial \dot i_q}{\partial \alpha_j}=-\frac{\omega}{L_q}\,\varphi_j(i_d,i_q,\omega).
  $$

  よって新しい回帰ベクトルは

  $$
  \boxed{\ \phi_{\alpha_j}=
  \begin{bmatrix}
  0\\[2pt]
  -\,(\omega/L_q)\,\varphi_j
  \end{bmatrix}}
  $$

  で、誤差 $e=\begin{bmatrix}e_d\\e_q\end{bmatrix}=\hat X-X$ との内積
  $\ \varepsilon_{\alpha_j}=\phi_{\alpha_j}^\top e= -(\omega/L_q)\,\varphi_j\,e_q$。

* もし $\Delta\phi_q=\sum \beta_k\chi_k$ も入れるなら

  $$
  \frac{\partial \dot i_d}{\partial \beta_k}=+\frac{\omega}{L_d}\,\chi_k,\quad
  \frac{\partial \dot i_q}{\partial \beta_k}=0
  \ \Rightarrow\
  \phi_{\beta_k}=\begin{bmatrix}
  +(\omega/L_d)\chi_k\\ 0
  \end{bmatrix}.
  $$

> **コツ**：**係数に対して線形**（$\Delta\phi=\sum\alpha_j\varphi_j$）にしておくと、$\phi$ がシンプルに書け、Popov の条件に寄せやすいです。
> $\varphi_j$ は $1,\,i_d,\,i_d^3,\,i_d i_q^2,\ldots$ の多項式や、正規化 B-spline/LUT の**局所基底**が扱いやすいです。

---

# 4) 実装手順（既存 MRAS 関数からの差分）

## (A) 可変モデルの微修正

先に配布した MRAS コードでは、調整モデルを行列（Â, B̂, Ĉ）で書いていましたが、Δφ は $i$ に依存する**非線形項**なので、**式を直接書く**のが簡単です：

```matlab
% -- Adjustable model RHS with Δφ --
% choose basis phi_d = [varphi_1(id_hat,iq_hat,omega); ...; varphi_M(...)]
phi_d = basis_d(id_hat, iq_hat, omega);     % Mx1
dphi_d = alpha.' * phi_d;                   % Δφ_d = Σ αj φj

% (if you also model Δφ_q)
% phi_q = basis_q(id_hat, iq_hat, omega);   % Nx1
% dphi_q = beta.' * phi_q;

di_d = (vd - Rs*id_hat + omega*(Lq*iq_hat /* + dphi_q */ )) / Ld;
di_q = (vq - Rs*iq_hat - omega*(Ld*id_hat + lam + dphi_d)) / Lq;

xhat = xhat + Ts*[di_d; di_q] + Ts*G*(xhat - [id; iq]);
```

## (B) 新パラメータの PI 適応を追加

```matlab
% regression for α (only Δφ_d used)
% phi_alpha_j = [0 ; -(omega/Lq)*varphi_j]
eps_alpha = -(omega/Lq) * (phi_d * e(2));   % Mx1 （各要素が ε_αj）
z_alpha   = z_alpha + Ts * eps_alpha;       % Mx1
alpha_new = alpha + Kp_alpha.*eps_alpha + Ki_alpha.*z_alpha;

% クリップ＋リーケージ（推奨）
alpha = min(max(alpha_new, alpha_min), alpha_max);
z_alpha = z_alpha - leak_alpha.*alpha;      % L2正則化的に暴走防止
```

> **おすすめ初期化**：$\alpha=0$ から開始（= Δφ なしの名目モデル）。
> **ゲイン**：はじめは $K_{p,\alpha}$ 小さく、$K_{i,\alpha}=0$ で慣らし → ゆっくり I を入れる。
> **正則化**：`leak_alpha` をごく小さく（例 $10^{-4}\sim10^{-3}$）入れるとドリフトを抑制。

---

# 5) 3つの現実的なパラメタライズ方法

1. **多項式基底（最小実装）**
   $\varphi=[1,\ i_d,\ i_d^3,\ i_d\,i_q^2]^\top$ など低次から。

   * 長所：実装容易、φ計算が軽い
   * 短所：外挿（高電流域）で暴れやすい → 係数に**クリップ**と**リーケージ**必須

2. **正規化B-spline/局所基底（推奨）**
   $i_d$ グリッドに B-spline を張り、局所サポートの $\varphi_j(i_d)$ を使用

   * 長所：局所調整で**安定**、推定係数の物理解釈（局所磁束バイアス）
   * 短所：テーブル点数に比例して係数が増える → PE（励振）設計が必要

3. **正規化LUT のバイリニア係数**（d–q 面）
   $\Delta\phi_d(i_d,i_q)$ を格子上で表し、**バイリニア重み**を $\alpha_j$ に

   * 長所：任意のマップに近似しやすい
   * 短所：係数が多く、PE が難しい → **領域を絞る** or **リッジ正則化**を強める

---

# 6) 安定性とチューニングの注意

* **線形-in-係数**を守る：$\Delta\phi=\sum\alpha_j\varphi_j$。
* **小さなゲインから**：特に $K_{p,\alpha},K_{i,\alpha}$ は $R_s$ や $\lambda_m$ よりも一段小さく。
* **PE（励振）**：$\omega$ と $i_q$ の変化が $\phi_{\alpha}$ に乗る（$-\omega/L_q$ が効く）ので、**中速 $\to$ FW 域**のシナリオを混ぜる。
* **リーケージ/正則化**：長期ドリフト対策に $ \dot{\alpha} \leftarrow \dot{\alpha} - \eta\,\alpha$（小 $\eta$）。
* **物理拘束**：$\alpha$ は $[-\alpha_{\max},\alpha_{\max}]$ でクリップ。Δφ の絶対値に上限を。

---

# 7) 最小“差分コード”例（先の MRAS に足す）

```matlab
% 追加の persistent
persistent alpha z_alpha
if isempty(alpha)
    M = 3;                      % 例: 基底 φ=[1, id_hat, id_hat.^3]
    alpha   = zeros(M,1);
    z_alpha = zeros(M,1);
end

% 基底（要: 任意の i,ω 依存でOK）
phi_d = [ 1;
          id_hat;
          id_hat^3 ];

% Δφ の評価
dphi_d = alpha.' * phi_d;

% 可変モデル（Δφ を含む）
di_d = (vd - Rs*id_hat + omega*(Lq*iq_hat        )) / Ld;
di_q = (vq - Rs*iq_hat - omega*(Ld*id_hat + lam + dphi_d)) / Lq;

xhat = xhat + Ts*[di_d; di_q] + Ts*G*(xhat - [id; iq]);
e    = xhat - [id; iq];

% α の回帰量と適応（Δφ_d のみ）
eps_alpha = -(omega/Lq) * (phi_d * e(2));      % Mx1
z_alpha   = z_alpha + Ts*eps_alpha;

Kp_alpha = 1e-5*ones(M,1);   % まずはとても小さく
Ki_alpha = 1e-6*ones(M,1);
leak     = 1e-4;

alpha_new = alpha + Kp_alpha.*eps_alpha + Ki_alpha.*z_alpha - leak*alpha;
alpha_min = -0.02 * ones(M,1);  % 例: ±0.02 Wb 相当の範囲
alpha_max = +0.02 * ones(M,1);
alpha     = min(max(alpha_new,alpha_min),alpha_max);
```

> はじめは **M=1（定数バイアス）→ M=2（+id）→ M=3（+id³）** と段階的に増やすのがおすすめです。

---

## まとめ

* **はい、Δφ モデルは MRAS で実装できます。**
* 重要なのは **係数に対して線形**なパラメタライズにすること、そして**小さなゲイン・局所基底・正則化**で安定に慣らすこと。
* まずは d 軸の Δφ だけ・低次基底から始め、収束・トレンドが掴めたら q 軸側や高次基底に広げると安全です。

必要なら、この差分を**前回の MRAS MatlabFunction に統合した完全版**や、**B-spline 基底版**（グリッド指定で自動生成）を作ってお渡しします。どちらにしますか？
