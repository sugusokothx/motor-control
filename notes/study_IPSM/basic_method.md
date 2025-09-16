
---

# STEP1

## 式 (1) – 電気方程式（dq 軸電圧方程式）

$$
\begin{aligned}
\frac{di_d}{dt} &= \frac{1}{L_d}\Bigl(v_d - R_s i_d + \omega L_q i_q\Bigr) \\
\frac{di_q}{dt} &= \frac{1}{L_q}\Bigl(v_q - R_s i_q - \omega (L_d i_d + \lambda_m)\Bigr)
\end{aligned}
$$

### シンボルの説明

| 記号          | 意味                       | 単位       |
| ----------- | ------------------------ | -------- |
| $i_d, i_q$  | **ステータ電流**の dq 成分（直軸/横軸） | \[A]     |
| $v_d, v_q$  | **ステータ電圧**の dq 成分        | \[V]     |
| $R_s$       | ステータ巻線抵抗                 | \[Ω]     |
| $L_d, L_q$  | d軸／q軸インダクタンス             | \[H]     |
| $\lambda_m$ | **永久磁石磁束リンク**（d軸方向に固定）   | \[Wb]    |
| $\omega$    | **電気角速度**（ロータ電気角速度）      | \[rad/s] |

> **ポイント**
>
> * 右辺第1項は「印加電圧」、第2項は「抵抗降下」、第3項は「回転電圧（速度起電力）」。
> * dq座標では、回転する座標系の影響として「クロス結合項」(例：$+\omega L_q i_q$) が現れるのが特徴です。
> * $i_d$ の方程式は主に**磁束**、$i_q$ の方程式は主に**トルク**に寄与します。

---

## 式 (2) – 電磁トルク方程式

$$
T_e = \frac{3}{2}p_p\bigl(\lambda_m i_q + (L_d - L_q)i_d i_q \bigr)
$$

### シンボルの説明

| 記号          | 意味                   | 単位    |
| ----------- | -------------------- | ----- |
| $T_e$       | 電磁トルク                | \[Nm] |
| $p_p$       | **極対数**（磁極ペア数）       | \[-]  |
| $L_d - L_q$ | d-q インダクタンス差（サリエンシー） | \[H]  |

> **ポイント**
>
> * 第1項 $\lambda_m i_q$：永久磁石磁束と q 軸電流による**主トルク成分**。
> * 第2項 $(L_d - L_q)i_d i_q$：サリエンシーによるトルク（**リラクタンストルク**）。
> * IPMSM では $L_d \neq L_q$ なので、\*\*MTPA（最大トルク/電流制御）\*\*の最適化が必要になります。

---

## 式 (3) – 機械方程式

$$
J \frac{d\omega_m}{dt} = T_e - T_l - F\omega_m
$$

### シンボルの説明

| 記号         | 意味                                                 | 単位           |
| ---------- | -------------------------------------------------- | ------------ |
| $J$        | 慣性モーメント（ロータ＋負荷）                                    | \[kg·m²]     |
| $\omega_m$ | **機械角速度**（rad/s）<br>電気角速度は $\omega = p_p \omega_m$ | \[rad/s]     |
| $T_l$      | 負荷トルク                                              | \[Nm]        |
| $F$        | 粘性摩擦係数                                             | \[N·m·s/rad] |

> **ポイント**
>
> * 電磁トルクと負荷トルクの差がロータ加速度を決定。
> * 摩擦項 $F\omega_m$ は速度比例の損失をモデル化。
> * ここを積分すると回転数（速度）応答が得られます。

---

## まとめ（まず押さえるべき基礎）

* **式 (1)**：電気系（L,R,クロス結合）→「電流応答」を支配
* **式 (2)**：電磁変換→「トルク発生」
* **式 (3)**：機械系（J,F）→「速度応答」

これら3式が揃うと、**入力：電圧指令 → 出力：速度・トルク**までのフル状態モデルが完成します。
制御器設計（PI調整、MTPA、FW）やパラメータ推定（Rs, Ld/Lq, λm）はすべてこのモデルを基礎にしています。

---

次のステップとして、**式 (1) の導出プロセス**をじっくり追ってみると理解が深まります。
（Clarke変換 → Park変換 → 回転座標系での微分 → dq電圧方程式の導出）を数式で展開しましょうか？
実際に紙に書いて整理すると、クロス結合項や $\omega \lambda_m$ 項がどこから出てくるかが見えてきます。やりますか？



# STEP2

式(1)→(2)→(3)がどこから来るのかを、abc系 → αβ系（Clarke）→ dq系（Park）の順に“導出の道筋”でまとめます。最後にコンパクトな要点も置きます。

---

## 1) abc → αβ（Clarke 変換）

三相の相電流・電圧 $(i_a,i_b,i_c),(v_a,v_b,v_c)$ を二相直交座標に射影します（零相は省略）：

$$
\begin{aligned}
\begin{bmatrix} i_\alpha \\ i_\beta \end{bmatrix}
&= \frac{2}{3}
\begin{bmatrix}
1 & -\tfrac12 & -\tfrac12\\[2pt]
0 & \tfrac{\sqrt{3}}{2} & -\tfrac{\sqrt{3}}{2}
\end{bmatrix}
\begin{bmatrix} i_a\\ i_b\\ i_c \end{bmatrix}, \\
\begin{bmatrix} v_\alpha \\ v_\beta \end{bmatrix}
&= \frac{2}{3}
\begin{bmatrix}
1 & -\tfrac12 & -\tfrac12\\[2pt]
0 & \tfrac{\sqrt{3}}{2} & -\tfrac{\sqrt{3}}{2}
\end{bmatrix}
\begin{bmatrix} v_a\\ v_b\\ v_c \end{bmatrix}.
\end{aligned}
$$

（ここは標準形。論文は式(1)〜(3)がPMSMモデルの基礎であることを前置きしており、式(1)が電気方程式、式(2)が電磁トルク、式(3)が機械方程式だと明記しています。）

---

## 2) αβ → dq（Park 変換）

回転子電気角 $\theta$（$\dot\theta=\omega$）に同期する回転座標へ回します：

$$
\begin{bmatrix} x_d \\ x_q \end{bmatrix}
=
\begin{bmatrix}
\cos\theta & \sin\theta\\
-\sin\theta & \cos\theta
\end{bmatrix}
\begin{bmatrix} x_\alpha \\ x_\beta \end{bmatrix}
\quad(x=i,v,\psi\ \text{など})
$$

このとき、**回転座標の時間微分**には座標の回転由来の項が出ます：

$$
\frac{d}{dt}\begin{bmatrix} x_d \\ x_q \end{bmatrix}
=
\begin{bmatrix} \dot x_d \\ \dot x_q \end{bmatrix}
=
\underbrace{
\begin{bmatrix}
\cos\theta & \sin\theta\\
-\sin\theta & \cos\theta
\end{bmatrix}}_{\text{Park}}
\begin{bmatrix} \dot x_\alpha \\ \dot x_\beta \end{bmatrix}
+
\omega
\begin{bmatrix}
0 & 1\\
-1 & 0
\end{bmatrix}
\begin{bmatrix} x_d \\ x_q \end{bmatrix}.
$$

この最後の項が、\*\*クロス結合（$\pm \omega$ の項）\*\*の源泉です。

---

## 3) dq 電圧方程式の導出（式(1)の形へ）

PMSM の相インダクタンスは、回転座標では $L_d, L_q$ に対角化され、磁束リンクは

$$
\psi_d = L_d i_d + \lambda_m,\qquad \psi_q = L_q i_q
$$

となります（$\lambda_m$ はPMのd軸固定成分）。

電圧は「巻線抵抗降下＋磁束時間変化」：

$$
\begin{aligned}
v_d &= R_s i_d + \frac{d\psi_d}{dt} - \omega\,\psi_q,\\
v_q &= R_s i_q + \frac{d\psi_q}{dt} + \omega\,\psi_d.
\end{aligned}
$$

（先ほどの“回転微分”の交差項が $\mp\omega\psi_{q,d}$）

$\psi_d,\psi_q$ を代入し、時間微分 $\tfrac{d}{dt}(L_d i_d)=L_d \dot i_d$（$L_d,L_q$一定仮定）で整理すると：

$$
\boxed{
\begin{aligned}
v_d &= R_s i_d + L_d \dot i_d - \omega L_q i_q,\\
v_q &= R_s i_q + L_q \dot i_q + \omega (L_d i_d + \lambda_m).
\end{aligned}}
$$

両辺を $L_d,L_q$ で割れば、論文の式(1)と等価な

$$
\dot i_d = \frac{1}{L_d}(v_d - R_s i_d + \omega L_q i_q),\quad
\dot i_q = \frac{1}{L_q}(v_q - R_s i_q - \omega(L_d i_d + \lambda_m))
$$

が得られます（式(1)が「電気方程式」である旨は論文に明記。）。

---

## 4) 電磁トルク式（式(2)）の導出スケッチ

PMSM の電磁トルクは**共エネルギー**から

$$
T_e = \frac{3}{2}p_p(\psi_d i_q - \psi_q i_d)
$$

が基本形。ここに $\psi_d=L_d i_d+\lambda_m,\ \psi_q=L_q i_q$ を代入すると

$$
\boxed{
T_e = \frac{3}{2}p_p\bigl(\lambda_m i_q + (L_d - L_q)i_d i_q\bigr)
}
$$

となります。第1項が“PM×q電流”の主トルク、第2項がサリエンシ由来（IPMSMで顕著）。論文では式(2)が「電磁トルク」の式として提示されています。

---

## 5) 機械方程式（式(3)）

回転系の運動は

$$
J\dot\omega_m = T_e - T_l - F\omega_m
$$

（必要に応じて風損などの高次損失を追加）。電気角速度は $\omega = p_p\,\omega_m$。論文では式(3)が「機械方程式」であるとされています。

---

## 要点（ここが肝）

* **Park微分の$\omega$項**が、式(1)のクロス結合（$\pm\omega$）を生む。
* $\psi_d = L_d i_d+\lambda_m,\ \psi_q=L_q i_q$ を入れると、dq電圧式と\*\*PM起電力 $\omega\lambda_m$\*\*が自然に出る。
* トルクは $\tfrac{3}{2}p_p(\psi_d i_q - \psi_q i_d)$ → **PMトルク + リラクタンス・トルク**。
* 機械はニュートンの運動方程式に $\omega=p_p\omega_m$ を結び付ければ完結。

---

次は、**(i)** Park微分の導出を手書きで追えるように“行列式での一段ずつの展開”、**(ii)** 上の式から\*\*式(1)の形（$\dot i_d,\dot i_q$ 片側）\*\*までの整理を“1行ずつ”書き下します。さらに、\*\*等価回路図（dq軸のR–Lと速度起電力）\*\*も描くと視覚的に腹落ちします。

# STEP3

ここでは「式(1)の完全導出」を中心に、Park 変換の“微分に伴うω項”を行列表記で一段ずつ出し、最後に式(2)(3)の出どころも最小限で押さえます

---

## 1) abc → αβ（Clarke）

三相（中性点なし）を二相直交へ：

$$
\begin{bmatrix}x_\alpha\\x_\beta\end{bmatrix}
=\frac{2}{3}\begin{bmatrix}
1&-\tfrac12&-\tfrac12\\
0&\tfrac{\sqrt3}{2}&-\tfrac{\sqrt3}{2}
\end{bmatrix}\begin{bmatrix}x_a\\x_b\\x_c\end{bmatrix}\qquad(x=i,v,\psi)
$$

（零相は省略。ここは定番変換で、最終的に式(1)の dq 電圧方程式に集約されます ）

---

## 2) αβ → dq（Park）と「回転微分」の正確な導出

回転子電気角 $\theta(t)$（$\dot\theta=\omega$）に同期する座標へ：

$$
\begin{bmatrix}x_d\\x_q\end{bmatrix}
=R(\theta)\begin{bmatrix}x_\alpha\\x_\beta\end{bmatrix},\quad
R(\theta)=\begin{bmatrix}\cos\theta&\sin\theta\\-\sin\theta&\cos\theta\end{bmatrix}.
$$

時間微分を厳密に取ります：

$$
\frac{d}{dt}\!\begin{bmatrix}x_d\\x_q\end{bmatrix}
=\dot R(\theta)\!\begin{bmatrix}x_\alpha\\x_\beta\end{bmatrix}
+R(\theta)\!\begin{bmatrix}\dot x_\alpha\\\dot x_\beta\end{bmatrix}.
$$

$$
\dot R(\theta)
=\omega\begin{bmatrix}-\sin\theta&\cos\theta\\-\cos\theta&-\sin\theta\end{bmatrix}
=\omega\,R(\theta)\!\begin{bmatrix}0&1\\-1&0\end{bmatrix}.
$$

よって

$$
\boxed{\ \dot{\boldsymbol x}_{dq}
=R(\theta)\,\dot{\boldsymbol x}_{\alpha\beta}
+\omega\underbrace{\begin{bmatrix}0&1\\-1&0\end{bmatrix}}_{J}
\boldsymbol x_{dq}\ }.
$$

この $+\omega Jx_{dq}$ が\*\*クロス結合（$\pm\omega$）\*\*の源泉です。

---

## 3) dq 電圧方程式の導出（式(1)へ到達）

（i）電圧の基本式：
相インダクタンスを含む巻線の端子電圧は

$$
\boldsymbol v=R_s\,\boldsymbol i+\frac{d\boldsymbol\psi}{dt}.
$$

（ii）dq 上の磁束リンク：

$$
\psi_d=L_d i_d+\lambda_m,\qquad \psi_q=L_q i_q.
$$

（iii）Park の「回転微分」を磁束に適用：

$$
\begin{aligned}
v_d&=R_s i_d+\frac{d\psi_d}{dt}-\omega\,\psi_q,\\
v_q&=R_s i_q+\frac{d\psi_q}{dt}+\omega\,\psi_d.
\end{aligned}
$$

（iv）$\tfrac{d}{dt}(L_d i_d)=L_d\dot i_d$（$L_d,L_q$一定仮定）を代入して整理：

$$
\boxed{
\begin{aligned}
v_d &= R_s i_d + L_d \dot i_d - \omega L_q i_q,\\
v_q &= R_s i_q + L_q \dot i_q + \omega (L_d i_d + \lambda_m).
\end{aligned}}
$$

両辺を $L_d,L_q$ で割って $\dot i_d,\dot i_q$ を左辺に出すと、論文の式(1)と同値の形：

$$
\boxed{
\begin{aligned}
\dot i_d &= \frac{1}{L_d}\bigl(v_d - R_s i_d + \omega L_q i_q\bigr),\\
\dot i_q &= \frac{1}{L_q}\bigl(v_q - R_s i_q - \omega (L_d i_d + \lambda_m)\bigr).
\end{aligned}}
$$

（式(1)が電気方程式であることは本文で示されています ）

---

## 4) 式(2)（電磁トルク）の出どころ（最短ルート）

共エネルギーの一般式

$$
T_e=\frac{3}{2}p_p(\psi_d i_q-\psi_q i_d)
$$

に $\psi_d=L_d i_d+\lambda_m,\ \psi_q=L_q i_q$ を代入：

$$
\boxed{T_e=\frac{3}{2}p_p\bigl(\lambda_m i_q+(L_d-L_q)i_d i_q\bigr)}.
$$

第1項＝PM×q軸電流の主トルク、第2項＝サリエンシ由来（IPMSM で有効）。論文の式(2)がこの**電磁トルク式**です 。

---

## 5) 式(3)（機械）も一行で接続

回転系の運動方程式：

$$
\boxed{J\dot\omega_m=T_e-T_l-F\omega_m, \quad \omega=p_p\,\omega_m}
$$

（式(3)＝機械方程式として提示） 。

---

## 6) 直観図（dq 等価回路の素描）

```
d軸：  vd → [ Rs ]—[ Ld ]→ id   ＋(−ω Lq iq) が“注入”される（結合項）

q軸：  vq → [ Rs ]—[ Lq ]→ iq   ＋(+ω Ld id + ω λm) が“注入”される（結合＋PM起電力）
```

* 角速度 ω に比例する“速度起電力”が、dq で互いに注入されます。
* q軸の $+\omega\lambda_m$ が**PM 起電力**（誘起電圧）の本体。

---

## 7) チェックリスト（式(1)を自分で再導出できるように）

1. Park 行列 $R(\theta)$ と $\dot R(\theta)=\omega R(\theta)J$ を暗唱。
2. $\boldsymbol v=R_s\boldsymbol i+\tfrac{d\boldsymbol\psi}{dt}$ を dq に持ち込むと、$\pm\omega\psi$ が自動的に出る。
3. $\psi_d=L_d i_d+\lambda_m,\ \psi_q=L_q i_q$ を代入して整理。
4. 右辺の $\pm\omega$ 項の符号に注意（d式は −ωLq iq、q式は +ω(Ld id+λm)）。

---



