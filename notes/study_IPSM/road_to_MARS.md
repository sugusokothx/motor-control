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

必要なら、このメモを**Matlab/Simulink のブロック化**に直結できる**MatlabFunction 雛形**や、**Python テストスクリプト**（合成プラント＋推定器）の“最小実行セット”に整えてお渡しします。どちらから行きますか？

