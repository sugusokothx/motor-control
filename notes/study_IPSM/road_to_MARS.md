紙と鉛筆で自分のノートにまとる。\
式(1)を「状態空間形」に整理 → それを足場に式(2)(3)を“同じノート上”で一体化する手順を書きます。論文が式(1)〜(3)をPMSMの電気・トルク・機械モデルとして示していること、また $\dot X=AX+BU+C$ 形式（式(5)）を導入していることは本文に明記されています。&#x20;

---

# 1) 状態と入力の定義（まず箱を書いておく）

* 状態 $X := \begin{bmatrix} i_d \\ i_q \end{bmatrix}$
* 入力 $U := \begin{bmatrix} v_d \\ v_q \end{bmatrix}$
* パラメータ：$R_s,\ L_d,\ L_q,\ \lambda_m,\ \omega$（電気角速度。必要なら $\omega=p_p\omega_m$ で機械側とつなぐ）

式(1)（dq電圧方程式）を「$\dot X = AX + BU + C$」にしたい（論文の式(5)の形）。

---

# 2) 式(1)をそのまま縦に並べる（左＝$\dot X$）

$$
\begin{aligned}
\dot i_d &= \tfrac{1}{L_d}\bigl(v_d - R_s i_d + \omega L_q i_q \bigr),\\
\dot i_q &= \tfrac{1}{L_q}\bigl(v_q - R_s i_q - \omega(L_d i_d + \lambda_m) \bigr).
\end{aligned}
$$

これを

$$
\dot X = A\,X + B\,U + C
$$

の項に**色分けするつもりで**仕分けします（A：$i_d,i_q$に掛かっている係数、B：$v_d,v_q$の係数、C：定数項）。

---

# 3) 行列 $A,B,C$ を1行ずつ作る（最重要・ノートに太枠）

* 係数行列 $A$（状態に掛かる項）：

$$
A=
\begin{bmatrix}
-\dfrac{R_s}{L_d} & \ \ \dfrac{\omega L_q}{L_d}\\[10pt]
-\dfrac{\omega L_d}{L_q} & -\dfrac{R_s}{L_q}
\end{bmatrix}
$$

* 入力行列 $B$（電圧に掛かる項）：

$$
B=
\begin{bmatrix}
\dfrac{1}{L_d} & 0\\[6pt]
0 & \dfrac{1}{L_q}
\end{bmatrix}
$$

* 定数ベクトル $C$（$\lambda_m$ だけが作る項）：

$$
C=
\begin{bmatrix}
0\\[4pt]
-\dfrac{\omega\,\lambda_m}{L_q}
\end{bmatrix}
$$

> こうして、**式(1) ≡ $\dot X=AX+BU+C$**（論文の式(5)の形）になります。以後、可変（推定）モデルでは $\hat A,\hat B,\hat C$ を同じ型で作る（論文の式(6)）。

---

## 3.1 等方近似（$L_d=L_q=L_s$）を書いておくと便利

IPMSM でなく表面磁石型（SPMSM）や近似で使うとき：

$$
A=
\begin{bmatrix}
-\dfrac{R_s}{L_s} & \ \ \omega\\[6pt]
-\omega & -\dfrac{R_s}{L_s}
\end{bmatrix},\quad
B=\dfrac{1}{L_s}I_2,\quad
C=\begin{bmatrix}0\\[4pt]-\dfrac{\omega\,\lambda_m}{L_s}\end{bmatrix}.
$$

---

# 4) 出力の定義（観測ベクトル）

同定や制御で「なにを読むか」も枠に書く：

* 電流センサがあるなら $Y=X=[i_d\ i_q]^\top$（電流観測）
* 電流だけを使うなら $C_y=I_2,\ D_y=0$ の出力方程式 $Y=C_yX+D_yU$

（論文のMRAS枠では、参照モデル（実機）と調整モデルの電流出力を突き合わせて誤差を作る構成です。）

---

# 5) 式(2)（電磁トルク）を同じページに併記

**トルク算式**（そのまま貼れる形）：

$$
\boxed{ \ T_e=\frac{3}{2}p_p\bigl(\lambda_m i_q + (L_d-L_q)i_d i_q\bigr) \ }
$$

* SPMSM（$L_d=L_q$）なら $T_e=\tfrac{3}{2}p_p\,\lambda_m i_q$ に簡約。
* 制御や同定の「評価量」に使うときは、$\hat L_d,\hat L_q,\hat\lambda_m$ を差し替えれば推定トルク。
  （式(2)が電磁トルク式であることは論文で明記。）&#x20;

---

# 6) 式(3)（機械）を続けて配置（$\omega$を結ぶ）

**機械方程式**：

$$
\boxed{\ J\dot\omega_m = T_e - T_l - F\,\omega_m,\quad \omega = p_p\,\omega_m \ }
$$

* 速度状態を含めるなら、拡張状態 $\tilde X=[\,i_d,\ i_q,\ \omega_m\,]^\top$ にして

  $$
  \dot\omega_m=\frac{1}{J}\bigl(T_e(i_d,i_q)-T_l-F\omega_m\bigr),
  $$

  と**3本目の状態方程式**を追加（非線形項 $i_d i_q$ を含む）。
  （式(3)が機械方程式であることは論文で明記。）&#x20;

---

# 7) ここまでの“紙ノート版テンプレ”まとめ

* 見開きで左ページに

  * $X=[i_d\ i_q]^\top,\ U=[v_d\ v_q]^\top$
  * $A,B,C$ を上の**太枠**で写経
  * 備考：$\omega=p_p\omega_m$
* 右ページに

  * $T_e$ の枠（IPM と SPMSM の2パターン）
  * 機械方程式の枠（$\dot\omega_m$）
  * **ブロック図メモ**：$\dot X=AX+BU+C \rightarrow i_{dq} \rightarrow T_e \rightarrow \dot\omega_m$

> これで、論文の式(1)〜(3)と式(5)の「核」が手元ノートに整理できました。
> 次の段では、この $A,B,C$ を **“推定版（ハット付き）”** に置き換え、論文の式(6)のように **調整モデル + $G$ での安定化**、そして**誤差ダイナミクス** → **PI型適応則**の順で“板書化”します（MRASの骨格）。

了解。ここからは**MRASの骨格**を紙ノートに写せるように、“調整（可変）モデル → 誤差ダイナミクス → PI型適応則”の順で、式だけにフォーカスしてまとめます。必要な根拠は論文の式(5)(6)(7)(8)(9)の流れに沿っています。

---

# A) 調整（可変）モデルの定義【論文の式(6)に対応】

* 参照（実機）モデルは、前回まとめた

  $$
  \dot X = A X + B U + C
  $$
* **調整（推定）モデル**（ハット付きパラメータで組む）：

  $$
  \boxed{\ \dot{\hat X} = \hat A\,\hat X + \hat B\,U + \hat C \;+\; G(\hat X - X)\ }
  $$

  * $X=[i_d,i_q]^\top,\ U=[v_d,v_q]^\top$
  * $\hat A,\hat B,\hat C$ は $\hat R_s,\hat L_d,\hat L_q,\hat\lambda_m,\omega$ から**式(1)の形**で構成
  * $G=\mathrm{diag}(k_1,k_2)$ は**安定化ゲイン**（Popov条件下で選定）

> メモ：この「参照モデルと並列に置いた**可変モデル＋出力誤差フィードバック**」という構成が論文のMRAS枠組みそのものです。

---

# B) 誤差ダイナミクス（ΔA,ΔB,ΔC で“ズレ”を明示）【式(7)】

* 誤差 $e:=\hat X - X$
* 参照と調整の差分から

  $$
  \boxed{\ \dot e \;=\; (A+G)\,e \;+\; \Delta A\,X \;+\; \Delta B\,U \;+\; \Delta C\ }
  $$

  ここで $\Delta A=\hat A-A,\ \Delta B=\hat B-B,\ \Delta C=\hat C-C$。

> 直感：誤差は「安定化項 $A+G$」で減衰しつつ、\*\*パラメータずれ（Δ）\*\*により駆動される。

---

# C) 回帰量（感度）の作り方（紙ノート用「偏微分メモ」）

式(1)の右辺（$\dot i_d,\dot i_q$）をパラメータ $\theta\in\{R_s,L_d,L_q,\lambda_m\}$ で偏微分した**感度ベクトル**を用意しておくと、適応則が作りやすい：

$$
\begin{aligned}
&\frac{\partial \dot i_d}{\partial R_s} = -\frac{i_d}{L_d},\quad
&&\frac{\partial \dot i_q}{\partial R_s} = -\frac{i_q}{L_q},\\[4pt]
&\frac{\partial \dot i_d}{\partial L_d} = -\frac{1}{L_d^2}(v_d - R_s i_d + \omega L_q i_q),\quad
&&\frac{\partial \dot i_q}{\partial L_q} = -\frac{1}{L_q^2}(v_q - R_s i_q - \omega(L_d i_d + \lambda_m)),\\[4pt]
&\frac{\partial \dot i_d}{\partial L_q} = \frac{\omega i_q}{L_d},\quad
&&\frac{\partial \dot i_q}{\partial L_d} = -\frac{\omega i_d}{L_q},\\[4pt]
&\frac{\partial \dot i_d}{\partial \lambda_m} = 0,\quad
&&\frac{\partial \dot i_q}{\partial \lambda_m} = -\frac{\omega}{L_q}.
\end{aligned}
$$

（ここでは $\omega$ 既知・一定、$L_d,L_q$ は推定対象でも**瞬時の微分では定数扱い**の近似）

→ これらを束ねて**回帰ベクトル** $\phi_\theta$ を定義（例）：

$$
\phi_{R_s}=\begin{bmatrix}-i_d/L_d\\ -i_q/L_q\end{bmatrix},\;
\phi_{L_d}=\begin{bmatrix}-\tfrac{v_d-R_s i_d+\omega L_q i_q}{L_d^2}\\ -\tfrac{\omega i_d}{L_q}\end{bmatrix},\;
\phi_{L_q}=\begin{bmatrix}\tfrac{\omega i_q}{L_d}\\ -\tfrac{v_q - R_s i_q - \omega(L_d i_d+\lambda_m)}{L_q^2}\end{bmatrix},\;
\phi_{\lambda}=\begin{bmatrix}0\\ -\omega/L_q\end{bmatrix}.
$$

> メモ：**紙ノートにはこの4つの $\phi_\theta$** を枠で書いておくと、後の適応則が一撃で書けます（論文の式(8)(9)が“誤差×回帰量”のPI形則であることに対応）。

---

# D) PI型適応則（連続時間の骨組み）【式(8)(9)に対応】

* 誤差 $e=\begin{bmatrix}e_d\\e_q\end{bmatrix}=\hat X-X$
* 各パラメータ $\theta\in\{R_s,L_d,L_q,\lambda_m\}$ ごとに

  $$
  \boxed{
  \begin{aligned}
  \varepsilon_\theta(t) &:= \phi_\theta(X,U,\hat\theta,\omega)^\top\,e(t) \quad\text{（“誤差に対する感度投影”）}\\
  \dot z_\theta(t) &= \varepsilon_\theta(t) \quad\text{（積分器の内部状態）}\\
  \dot{\hat\theta}(t) &= k_{\theta p}\,\varepsilon_\theta(t) + k_{\theta i}\, z_\theta(t)
  \end{aligned}}
  $$

  * $k_{\theta p},k_{\theta i}>0$：PIゲイン（小さく、Lや$\lambda_m$は特にゆっくり）
  * 物理クリップ：$\hat R_s>0,\ \hat L_{d,q}\in[L_{\min},L_{\max}],\ \hat\lambda_m>0$

> 直感：$\varepsilon_\theta=\phi_\theta^\top e$ は「**今の誤差が、$\theta$ を増やすべきか減らすべきか**」を教える符号＋重み。PIで**定常オフセット**も消す。Popovの枠組み（線形前向きブロックの正実性＋非線形フィードバックの積分不等式）に対応した形です。

---

# E) 全体ブロック（ノートに描く簡易図）

```
          ┌──────────────┐
 U=[vd,vq]│   参照モデル  │→ X=[id,iq] ──┐
          └──────────────┘              │
                                          │ e=Ẋ−X
          ┌──────────────┐              ▼
 U=[vd,vq]│ 調整モデル(Â, B̂, Ĉ)+G(·) │ → Ẋ
(θ̂で構成)└──────────────┘              │
                                          │
             ┌──────────────┐            │
             │   適応器 PI   │◄── φ_θ^T e─┘
             └──────────────┘      （θ̂更新）
```

---

# F) チェックリスト（手元ノートで確認）

1. **A,B,C**（または等方近似の $L_s$ 版）を左ページの太枠に固定（式(1)→式(5)の形）。
2. 可変モデル $\hat A,\hat B,\hat C$ と **$G=\mathrm{diag}(k_1,k_2)$** を右上に（式(6)）。
3. 誤差ダイナミクスの箱 $\dot e=(A+G)e+\Delta A X+\Delta B U+\Delta C$ を中央に（式(7)）。
4. 下段に **$\phi_\theta$** 一覧と **PI適応則**（式(8)(9)の骨格）。

---

次の段で**離散時間（サンプル周期 $T_s$）版**にして、**ゲイン初期値**・**クリップ範囲**・\*\*ノイズ対策（前処理/平滑）\*\*の順に実装ノートへ落としていきましょう。


ここからは\*\*離散時間版（実装ノート）\*\*に落とし込みます。紙ノートに“そのまま書ける”形で、更新式→ゲイン設計→クリップ/アンチワインドアップ→ノイズ対策→初期化＆検証の順にまとめます。（連続時間の骨格は論文の式(5)(6)(7)(8)(9)に相当します。）

---

# 1) 調整モデルの離散化（前進オイラー推奨スタート）

連続時間（論文の形）
$\dot{\hat X}= \hat A\hat X + \hat B U + \hat C + G(\hat X - X)$（式(6)の骨格）

離散時間（サンプル周期 $T_s$）

$$
\boxed{
\hat X_{k+1} = \hat X_k + T_s\Big(\hat A\hat X_k + \hat B U_k + \hat C + G(\hat X_k - X_k)\Big)
}
$$

* はじめは前進オイラーで十分。剛性が高ければ**Tustin**や**行列指数**（$\Phi=e^{\hat A T_s}$）へ格上げ。

誤差

$$
\boxed{e_k=\hat X_k - X_k}
$$

（誤差ダイナミクスの骨格は式(7)に対応）

---

# 2) 回帰ベクトル（感度）の用意（紙ノート再掲）

式(1)からの偏微分に基づく簡便な $\phi_\theta$（先に導出した形をそのまま使う）：

$$
\begin{aligned}
\phi_{R_s}&=\begin{bmatrix}-i_d/L_d\\ -i_q/L_q\end{bmatrix},\quad
\phi_{\lambda}=\begin{bmatrix}0\\ -\omega/L_q\end{bmatrix},\\
\phi_{L_d}&=\begin{bmatrix}-\tfrac{v_d-R_s i_d+\omega L_q i_q}{L_d^2}\\ -\tfrac{\omega i_d}{L_q}\end{bmatrix},\quad
\phi_{L_q}=\begin{bmatrix}\tfrac{\omega i_q}{L_d}\\ -\tfrac{v_q - R_s i_q - \omega(L_d i_d+\lambda_m)}{L_q^2}\end{bmatrix}.
\end{aligned}
$$

---

# 3) PI 形適応則の**離散化**

連続時間の骨格（式(8)(9)）
$\varepsilon_\theta=\phi_\theta^\top e,\ \dot z_\theta=\varepsilon_\theta,\ \dot{\hat\theta}=k_{\theta p}\varepsilon_\theta+k_{\theta i}z_\theta$

離散時間：

$$
\boxed{
\begin{aligned}
\varepsilon_{\theta,k} &= \phi_{\theta,k}^\top\, e_k \\
z_{\theta,k+1} &= z_{\theta,k} + T_s\,\varepsilon_{\theta,k} \\
\hat\theta_{k+1} &= \operatorname{sat}\!\Big(\hat\theta_k + k_{\theta p}\,\varepsilon_{\theta,k} + k_{\theta i}\,z_{\theta,k+1}\Big)
\end{aligned}}
$$

* $\operatorname{sat}(\cdot)$：**物理クリップ**（後述）
* $\theta \in \{R_s,\ L_d,\ L_q,\ \lambda_m\}$

---

# 4) 物理クリップ & アンチワインドアップ

**クリップ範囲の目安**（PMSM一般）

* $R_s\in[R_{\min},R_{\max}] \approx [0.5,\,1.5]\times R_{s,\text{nom}}$
* $L_d,L_q\in[L_{\min},L_{\max}] \approx [0.5,\,1.5]\times L_{\text{nom}}$
* $\lambda_m > 0$、運転温度域で±10–20% 程度

**アンチワインドアップ**（推奨：クランプ方式）

* クリップにかかったら、そのパラメータの**積分器を凍結**：

  $$
  \text{if } \hat\theta_{k+1}\text{ clipped } \Rightarrow z_{\theta,k+1} = z_{\theta,k}
  $$

  （または**バック計算法**：$z\leftarrow z+\beta(\hat\theta-\hat\theta_\text{sat})$、$\beta>0$）

---

# 5) ゲイン設計（実務的な“始め方”）

* **安定化ゲイン $G=\mathrm{diag}(k_1,k_2)$**（調整モデル側）

  * 電流ループ帯域 $\omega_{ci}$ の 0.2〜0.5 倍を目安に：
    $\,k_1=k_2\approx (0.2\sim0.5)\,\omega_{ci}$（単位整合に注意）
  * はじめは**小さめ**に置き、誤差減衰が遅ければ増加（過大だとノイズに敏感）

* **適応器ゲイン（PI）**

  1. まず **P のみ**：
     $k_{R_s p}\sim10^{-3}\!-\!10^{-2},\ k_{L p}\sim10^{-5}\!-\!10^{-4},\ k_{\lambda p}\sim10^{-4}\!-\!10^{-3}$
     （単位系・スケーリングで調整）
  2. 収束が見えたら **I を少量追加**：
     $k_{\theta i} \approx (0.05\sim0.2)\,k_{\theta p}$
  3. **優先順位**：まず $R_s$ と $\lambda_m$ を安定に → その後 $L_d,L_q$

* **スケーリング**

  * $\phi_\theta$ の大きさが大きく異なるので、**正規化**（例：名目値で割る）を検討

---

# 6) ノイズ・整合対策（現場で効く小ワザ）

* **電流・電圧の直流オフセット除去**（毎周期 or ゆっくり推定）
* **軽い一次LPF**： $e_k \leftarrow (1-\alpha)e_k + \alpha e_{k-1}$（$\alpha\sim0.1$）
  同様に $\varepsilon_{\theta,k}$ に適用可
* **デッドバンド**：$|\varepsilon_{\theta,k}|<\epsilon$ のとき更新停止（微小ノイズで暴れない）
* **$\omega$ の整合**：FOCの位相と**同じ位相・同じ単位**で供給（$\omega=p_p\omega_m$の取り違え注意）
* **電圧モデルの整合**：PWM デッドタイム補正・座標変換遅れの補正（別途モデル改善）

---

# 7) 初期化とウォームアップ

* **初期値**：銘板・直流試験・LCR測定（論文もハード計測で突合）をベースに設定。
* **ウォームアップ**：最初の数百 ms は $k_{\theta p},k_{\theta i}$ を 0→目標値へ**リニアランプ**
* **運転点スケジューリング**：FW領域（$i_d<0$、高$\omega$）突入で**ゲインを下げる**と安定的

---

# 8) 最低限の擬似コード（1周期の実行順）

```
loop at Ts:
  measure id, iq, vd, vq, omega
  # adjustable model
  xhat = xhat + Ts*( Ahat(xhat,θhat,ω)*xhat + Bhat(θhat)*U + Chat(θhat,ω) + G*(xhat - X) )
  e    = xhat - X

  # regressors from (φθ)
  for θ in {Rs, Ld, Lq, lam}:
      eps = dot(φθ(X,U,θhat,ω), e)
      zθ  = zθ + Ts*eps
      θhat_new = θhat + kpθ*eps + kiθ*zθ
      θhat     = clip(θhat_new, θmin, θmax)
      if clipped: zθ = zθ - (θhat_new - θhat)/max(kiθ, tiny)  # anti-windup (optional)
```

---

# 9) 検証プロトコル（段階的に）

1. **定常回転**（中速・$i_d=0$）：$i_q$ を小ステップ → $R_s,\lambda_m$ が滑らかに収束
2. **FW 領域**（$i_d<0$）：$\omega$ 上げつつ安定性確認（必要ならゲイン下げ）
3. **温度変化**（連続運転）：$R_s$ の追従（論文でも高速域でのパラメータ変化を観測）
4. **ノイズ注入**：センサノイズ・位相ずれを模擬してロバスト性を確認

---

# STEP by STEP Section4

いいですね。Section 4「The identification algorithm」を“手を動かして理解できる”順番で、**7つの小ステップ**に分けて読み解きます。本文のどの式／表に対応しているかも、都度示します。

---

## ステップ1：章の全体像（何を、どうやって、何で安定化？）

* **ねらい**：PMSMの3パラメータ（$R_s, L, \lambda_m$ など）を**MRAS**でオンライン同定する。必要な信号は**電流・電圧・回転速度だけ**。図3が全体ブロック（参照モデルと調整モデルを並列に置き、電流誤差から適応器でパラメータ更新）。
* **安定性**：**POPOVハイパ安定性**に基づいて、前向き線形ブロック（正実）＋非線形フィードバック（積分不等式）という二つの条件で保証する。

> まずは「図3を自分のノートに写して」全体の信号の流れを把握しましょう（参照モデル→電流、調整モデル→推定電流、差を適応器に入れてパラメータ更新）。

---

## ステップ2：参照モデルを状態空間に（式(5)）

* 式(1)の電気方程式（前章の復習）から、**状態**$X=[i_d\ i_q]^\top$、**入力**$U=[v_d\ v_q]^\top$ をとり、

  $$
  \dot X = A X + B U + C \quad \text{（式(5)）}
  $$

  という**状態空間形**を作る。本文は「式(1)→式(5)」の流れを明記。
* $A,B,C$ の具体形は前章で導出済み（ノートへ転記してOK）。ここでは**参照（実機）モデル**として使う。

> ノートでは、左ページに $A,B,C$ を太枠で固定（これが**比較対象の“正”**）。

---

## ステップ3：調整（可変）モデルと安定化項G（式(6)）

* 同じ構造で**推定パラメータ**（ハット付き）を使った可変モデルを並列に置く：

  $$
  \dot{\hat X}=\hat A\,\hat X+\hat B\,U+\hat C\;+\;G(\hat X-X)\quad\text{（式(6)）}
  $$

  ここで $G=\mathrm{diag}(k_1,k_2)$ は**安定化用の出力誤差注入ゲイン**。&#x20;
* $k_1,k_2$ は**手動で与える正の定数**と明記（後でチューニング）。

> ノート右ページに $\hat A,\hat B,\hat C$ と $G$ を枠で記入。\*\*Gは“収束の速さ・滑らかさのつまみ”\*\*だと書き添えておく。

---

## ステップ4：誤差ダイナミクスを作る（式(7)）

* 参照（式(5)）と調整（式(6)）を引き算して、電流誤差 $e:=\hat X-X$ の微分を得る：

  $$
  \dot e=(A+G)e+\Delta A\,X+\Delta B\,U+\Delta C \quad\text{（式(7)）}
  $$

  ここで $\Delta A=\hat A-A$ など\*\*“パラメータずれ”\*\*が誤差を駆動することが明快。

> ノート中央にこの式を大書き。\*\*「左：減衰（$A+G$）、右：ずれの駆動（Δ）」\*\*と色分けしておくと後で効きます。

---

## ステップ5：MRASの二分割（表1）とPOPOV条件

* MRASでは、**前向き線形ブロック**と**非線形フィードバック**に分けて考える（表1）。前者は**正実**であること、後者は**積分不等式**（POPOV条件）を満たすことが安定条件。&#x20;
* 積分不等式は本文で次のように与えられる（$\gamma^2>0$）：

  $$
  \int_0^t w(\tau)\,e(\tau)\,d\tau \;\ge\; -\gamma^2 \quad(\forall t)
  $$

  **（式の提示行）**。

> ここは概念要所：**線形部は“素性よし”に設計、非線形部は“やり過ぎない”ようPI型に**——とメモ。

---

## ステップ6：PI型の適応則（式(8)）

* 上のPOPOV第2条件を満たす**PI型の適応則**を採用。本文は、**比例（p）＋積分（i）**の2項で、$\Delta A,\Delta B,\Delta C$ を更新する**一般形**を式(8)として与えている（被積分・比例項は、誤差とレグレッサの積に相当）。&#x20;
* 具体的には、「**電流誤差 $e$** と、**状態・入力由来の回帰量（本文では $X,U$ と関数 $f$）**」を組み合わせ、**比例ゲイン $k_{\cdot p}$** と **積分ゲイン $k_{\cdot i}$** で $\Delta A,\Delta B,\Delta C$ を更新する形。

> ノートでは、**「$\varepsilon=\phi^\top e$ を作る → $z$ を積分 → $\hat\theta \leftarrow \hat\theta + k_p\varepsilon + k_i z$**」という**3行レシピ**を書き、$\phi$ が「どのパラメータの感度か」を横にメモ。

---

## ステップ7：パラメータ式への落とし込み（式(9)）

* 最後に、**実際のパラメータ（$R_s, L, \lambda_m$ など）**へ写像した式が**式(9)**。本文は、PI型ゲイン（$k_{\mathrm{pr}},k_{\mathrm{ir}}$ 等）と、誤差×回帰量の形で、各パラメータの更新式を並べて提示している。
* 図4以降は実験セットアップと結果（ここでは“式(9)で回した”推定の実データ比較が続く）。

> ノートでは、**「Rs行」「L行」「λ行」**の3本を作り、各行に**比例項＋積分項**を書き、最後に\*\*物理クリップ（下限・上限）\*\*を囲みで追記しておくと実装に直結します。

---

### ここまでの“写経チェックリスト”

* [ ] 図3の全体ブロック（参照／調整／誤差／適応器）を写した。
* [ ] 式(5)の $A,B,C$ を自分のノートに固定。
* [ ] 式(6)で $G=\mathrm{diag}(k_1,k_2)$ を明記（正の定数）。
* [ ] 式(7)の誤差ダイナミクスを色分け（左：減衰、右：ずれ駆動）。
* [ ] 表1の二分割とPOPOVの二条件（正実性／積分不等式）を書いた。&#x20;
* [ ] 式(8)のPI型一般式を3行レシピ化。
* [ ] 式(9)で各パラメータ更新式の形を並べ、ゲインとクリップ欄を用意。

---

この先は、**式(8)の“回帰量（$\phi$）をどう作るか”**をミクロに分解すると、一段理解が深まります。次回は、式(5)の右辺を各パラメータで偏微分して**感度ベクトル**を作り、\*\*式(8)の具体形（比例項・積分項の中身）\*\*を“ノートにそのまま書ける形”で整えましょう。続けますか？


了解です。ここからは式(8)の中身、つまり「回帰量（感度ベクトル）$\phi_\theta$」の作り方を丁寧に展開して、**PI適応則を具体式にする**ところまで進めます。ここが理解できると式(9)を“自分で再現”できます。

---

## ステップ1：もう一度、式(5)を思い出す

参照モデル（式(5)）：

$$
\dot X = AX + BU + C,\quad 
X=\begin{bmatrix}i_d\\ i_q\end{bmatrix},\ 
U=\begin{bmatrix}v_d\\ v_q\end{bmatrix}
$$

具体的には

$$
\begin{aligned}
\dot i_d &= \frac{1}{L_d}\bigl(v_d - R_s i_d + \omega L_q i_q\bigr),\\
\dot i_q &= \frac{1}{L_q}\bigl(v_q - R_s i_q - \omega(L_d i_d+\lambda_m)\bigr).
\end{aligned}
$$

→ これを各パラメータ $\theta\in\{R_s,L_d,L_q,\lambda_m\}$ で偏微分すれば、**感度ベクトル $\phi_\theta$** が得られます。

---

## ステップ2：偏微分して感度ベクトルを作る

### (a) $R_s$ に関する感度

$$
\frac{\partial \dot i_d}{\partial R_s} = -\frac{i_d}{L_d}, \quad
\frac{\partial \dot i_q}{\partial R_s} = -\frac{i_q}{L_q}
$$

$$
\boxed{\phi_{R_s} = 
\begin{bmatrix}
-\dfrac{i_d}{L_d}\\[4pt]
-\dfrac{i_q}{L_q}
\end{bmatrix}}
$$

---

### (b) $L_d$ に関する感度

$$
\dot i_d = \frac{1}{L_d}(v_d - R_s i_d + \omega L_q i_q)
\quad\Rightarrow\quad
\frac{\partial \dot i_d}{\partial L_d}
= -\frac{v_d - R_s i_d + \omega L_q i_q}{L_d^2}
$$

$$
\dot i_q = \frac{1}{L_q}(v_q - R_s i_q - \omega(L_d i_d+\lambda_m))
\quad\Rightarrow\quad
\frac{\partial \dot i_q}{\partial L_d}
= -\frac{\omega i_d}{L_q}
$$

$$
\boxed{\phi_{L_d} =
\begin{bmatrix}
-\dfrac{v_d - R_s i_d + \omega L_q i_q}{L_d^2}\\[6pt]
-\dfrac{\omega i_d}{L_q}
\end{bmatrix}}
$$

---

### (c) $L_q$ に関する感度

同様に

$$
\frac{\partial \dot i_d}{\partial L_q}
= \frac{\omega i_q}{L_d}, \qquad
\frac{\partial \dot i_q}{\partial L_q}
= -\frac{v_q - R_s i_q - \omega(L_d i_d+\lambda_m)}{L_q^2}
$$

$$
\boxed{\phi_{L_q} =
\begin{bmatrix}
\frac{\omega i_q}{L_d}\\[6pt]
-\frac{v_q - R_s i_q - \omega(L_d i_d+\lambda_m)}{L_q^2}
\end{bmatrix}}
$$

---

### (d) $\lambda_m$ に関する感度

$$
\frac{\partial \dot i_d}{\partial \lambda_m}=0, \quad
\frac{\partial \dot i_q}{\partial \lambda_m}=-\frac{\omega}{L_q}
$$

$$
\boxed{\phi_{\lambda_m}=
\begin{bmatrix}
0\\[6pt]
-\frac{\omega}{L_q}
\end{bmatrix}}
$$

---

## ステップ3：PI適応則に代入（式(8)の具体形）

論文の式(8)は一般形：

$$
\dot{\hat\theta}=k_{\theta p}\,\varepsilon_\theta + k_{\theta i}\!\int \varepsilon_\theta dt,
\quad
\varepsilon_\theta = \phi_\theta^\top e
$$

これを各パラメータで書くと：

$$
\boxed{
\begin{aligned}
\dot{\hat R_s} &= k_{Rp}\,\phi_{R_s}^\top e + k_{Ri} \int \phi_{R_s}^\top e \,dt \\
\dot{\hat L_d} &= k_{Lp}\,\phi_{L_d}^\top e + k_{Li} \int \phi_{L_d}^\top e \,dt \\
\dot{\hat L_q} &= k_{Qp}\,\phi_{L_q}^\top e + k_{Qi} \int \phi_{L_q}^\top e \,dt \\
\dot{\hat\lambda}_m &= k_{\lambda p}\,\phi_{\lambda_m}^\top e + k_{\lambda i} \int \phi_{\lambda_m}^\top e \,dt
\end{aligned}}
$$

ここで

* $e=\begin{bmatrix}e_d\\e_q\end{bmatrix}=\hat X-X$
* 各行は「比例項＋積分項」＝PI適応
* ゲイン $k_{\theta p},k_{\theta i}>0$ は調整パラメータ

---

## ステップ4：離散時間版にする

実装時はサンプル周期 $T_s$ で積分を近似：

$$
\begin{aligned}
z_{\theta,k+1}&=z_{\theta,k}+T_s\phi_{\theta,k}^\top e_k,\\[3pt]
\hat\theta_{k+1}&=\hat\theta_k+k_{\theta p}\phi_{\theta,k}^\top e_k+k_{\theta i}z_{\theta,k+1}
\end{aligned}
$$

これが論文の式(9)の**更新則の離散化**に相当します。

---

## ステップ5：安定性の保証（POPOV条件）

本文は、上記のように $\varepsilon_\theta=\phi_\theta^\top e$ を入力とするPI補償器が**Popovの積分不等式**を満たすことを示しています（表1＋積分不等式の記述）。

> ポイント：比例項が十分小さい、積分項が非負、という条件で「ハイパ安定性」が保証される。

---

## ステップ6：ノートにまとめるときのポイント

* 左ページに $\phi_\theta$ を4本並べて大枠
* 右ページに $\dot{\hat\theta}=k_p\phi_\theta^\top e+k_i\int\phi_\theta^\top e dt$ のテンプレ
* 下に「離散版」「クリップ条件」「アンチワインドアップ」を追加

---

次のステップでは、この更新式を**シミュレーションに組み込む準備**として、ゲインの初期値設定と、感度ベクトルの正規化（スケーリング）について具体的に見ていきますか？（どのくらいの大きさにすると安定して収束するかの目安です）


いいね。ここでは**ゲイン初期値の決め方**と**スケーリング（正規化）**、**シミュレーション準備**を“今すぐノートに写せる実務レシピ”でまとめます。土台は論文の Section 4（調整モデル＋誤差ダイナミクス＋PI適応の枠組み）です。可変モデルに安定化項 $G$ を入れて（式(6)）、誤差方程式（式(7)）を作り、PIの適応則（式(8)(9)）でパラメータを更新する流れに沿います。 &#x20;

---

# 1) まず“標準化（スケーリング）”から決める

**狙い**：回帰量 $\phi_\theta$ の桁を揃えて、1つのルールでゲインを選べるようにする。

* 名目値で無次元化

  $$
  \tilde i_d=\frac{i_d}{I_\text{nom}},\quad 
  \tilde v_d=\frac{v_d}{V_\text{nom}},\quad
  \tilde\omega=\frac{\omega}{\omega_\text{nom}}
  $$

  同様に $\tilde R_s=R_s/R_{s,\text{nom}}$, $\tilde L_d=L_d/L_{d,\text{nom}}$, $\tilde\lambda=\lambda_m/\lambda_{\text{nom}}$。
* **回帰量の正規化**：

  $$
  \tilde\phi_\theta=\frac{\phi_\theta}{\|\phi_\theta\|+\epsilon},\quad \epsilon\sim10^{-6}\ (\text{数値安定用})
  $$

  以後、**$\phi$ は $\tilde\phi$** を使う前提にすると、ゲイン設定が楽になります（式(8)の $\varepsilon_\theta=\phi_\theta^\top e$ にそのまま効く）。

---

# 2) 調整モデルの安定化ゲイン $G$（式(6)）

* 役割：誤差ダイナミクス $\dot e=(A+G)e+\cdots$ の**減衰**を強める。
* 初期値の経験則（電流ループ帯域 $\omega_{ci}$ を基準に）：

  $$
  G=\mathrm{diag}(k_1,k_2),\quad
  k_1=k_2\approx 0.2\sim0.5\ \omega_{ci}
  $$

  はじめは小さめ（例：$\omega_{ci}=2\pi\cdot1\ \mathrm{kHz}\Rightarrow k_{1,2}=600\sim3000$）。強すぎるとノイズ増幅・位相ズレに敏感。
  ※ $G$ は**正の定数**として置く設計が本文でも明示。

---

# 3) PI適応ゲインの“1行ルール”（式(8)(9)を離散化して使う）

離散時間（周期 $T_s$）で：

$$
\varepsilon_{\theta,k}=\tilde\phi_{\theta,k}^\top e_k,\quad
z_{\theta,k+1}=z_{\theta,k}+T_s\varepsilon_{\theta,k},\quad
\hat\theta_{k+1}=\hat\theta_k+k_{\theta p}\varepsilon_{\theta,k}+k_{\theta i}z_{\theta,k+1}.
$$



**推奨初期値（正規化前提）**

* $R_s$：$k_{p}\sim 10^{-3}\!-\!10^{-2},\ \ k_{i}\sim 0.05\!-\!0.2$×$k_{p}$
* $\lambda_m$：$k_{p}\sim 10^{-4}\!-\!10^{-3},\ \ k_{i}\sim 0.05\!-\!0.2$×$k_{p}$
* $L_d,L_q$：$k_{p}\sim 10^{-5}\!-\!10^{-4},\ \ k_{i}\sim 0.05\!-\!0.2$×$k_{p}$
  （**優先順位**：$R_s$→$\lambda_m$→$L_d,L_q$。まず P のみで様子見→I を少し足す）

**自動スケーリング案**（PEが弱い時に暴れにくい）

$$
k_{\theta p}=\frac{\alpha_\theta}{\bar \Phi_\theta+\delta},\;\;
\bar \Phi_\theta:=\text{EMA}\{\|\tilde\phi_{\theta,k}\|^2\},\ \delta\sim10^{-3},\ \alpha_\theta\in[10^{-3},10^{-1}]
$$

（“回帰量が小さいときにゲインを上げすぎない”安全弁）

---

# 4) クリップとアンチワインドアップ（必須）

* 物理範囲：
  $R_s\in[0.5,1.5]R_{s,\text{nom}}$,\ $L_{d,q}\in[0.5,1.5]L_{\text{nom}}$,\ $\lambda_m>0$
* クリップ時は**積分器凍結**：

  $$
  \text{if clipped}\Rightarrow z_{\theta,k+1}=z_{\theta,k}
  $$

  あるいは**バック計算法**：$z\leftarrow z+\beta(\hat\theta-\hat\theta_{\text{sat}})$, $\beta>0$。

---

# 5) シミュレーション準備（最短コース）

1. **プラント**：式(1)(2)(3)で dq プラント（必要なら $L_d=L_q$ の等方版から）
   → 状態空間 $\dot X=AX+BU+C$ をそのまま数値化（式(5)）。
2. **推定器**：調整モデル＋$G$（式(6)）と PI 適応（式(8)(9)）を離散化実装。&#x20;
3. **励振（PE）**：

   * 中速・$i_d=0$ で $i_q$ を ±小ステップ（$R_s,\lambda_m$ がよく見える）
   * FW域（$i_d<0$, $\omega$上げ）で $L_d,L_q$ の識別性を確保（小さめの擬正弦掃引や PRBS）
4. **ノイズと非理想**：電流±ノイズ、電圧オフセット、$\omega$ ゆらぎを入れてロバスト性確認。
5. **記録**：
   $\|e\|^2$、$\hat\theta$ の推移、$\sum_k \tilde\phi\tilde\phi^\top$ の条件数（PEの指標）。
6. **合格基準**：

   * $\|e\|^2$ が単調減少（バンプは可）
   * $\hat R_s$ が温度や $\omega$ 変化で**なめらかに追従**（論文でも高速域で $R_s$ 変動を観測）
   * $\hat\lambda_m$ は大きく揺れない（微減傾向：FWと整合）

---

# 6) 立ち上げ手順（そのまま運用メモ）

1. 初期 $\hat\theta=\theta_{\text{nom}}$、$G$ 小さめ、適応は **Pのみ**（Iは0）。
2. 中速・$i_d=0$ で $i_q$ ステップ：$\hat R_s,\hat\lambda_m$ の収束を観察。
3. I を**少量**入れる → 定常オフセットが消えるか確認。
4. $\omega\uparrow$, $i_d<0$（FW）へ展開：$L_d,L_q$ の更新を解放、ゲインは一段階**下げる**。
5. クリップ・アンチワインドアップの**作動ログ**を必ず残す（過学習の早期発見）。

---

# 7) つまずき診断（ありがち症状→対策）

* **誤差が発散気味**：$G\downarrow$, $k_{\theta p}\downarrow$, I項OFF、$\epsilon,\delta$ を増やす。
* **推定が止まる**（学習しない）：励振不足 → $i_q$ ステップ幅↑、微小掃引追加。
* **ノイズでギザギザ**：$\varepsilon_\theta$ と $e$ に一次LPF（$\alpha\sim0.1$）、デッドバンド導入。
* **$\hat L$ が端で張り付く**：範囲広げる、I項凍結、$k_{Lp}\downarrow$、FWでの励振設計見直し。
* **$\hat\lambda_m$ が過小**：$k_{\lambda p},k_{\lambda i}\downarrow$、$\omega$ の位相ズレ確認、電圧オフセット補正。

---

## 付箋：根拠（論文の該当箇所）

* **可変モデル＋誤差注入 $G$**：式(6)・図示の並列構成。
* **誤差ダイナミクス**：$\dot e=(A+G)e+\Delta A X+\Delta B U+\Delta C$（式(7)）。
* **PI適応の一般形**：式(8) と式(9)（比例＋積分でパラメータ更新）。&#x20;
* **高速域でのパラメータ変動の実測**（$R_s$ 上昇、$\lambda_m$ 微減）：実験結果の記述。

---

 <EOF>
