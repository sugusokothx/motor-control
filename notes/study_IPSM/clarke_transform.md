ナイスな突っ込みです。結論だけ先に：

* \*\*電力不変（power-invariant）\*\*での $\alpha\beta$／$dq$ では

  $$
  P \;=\; \lVert \mathbf V\rVert\,\lVert \mathbf I\rVert \cos\theta
  $$

  と**そのまま書けます（3/2は不要）**。

* \*\*振幅不変（amplitude-invariant）\*\*での $\alpha\beta$／$dq$ では

  $$
  P \;=\; \tfrac{3}{2}\,\lVert \mathbf V\rVert\,\lVert \mathbf I\rVert \cos\theta
  $$

  と**3/2が必要**です。

以下、なぜそうなるかの要点だけ。

---

## なぜ 3/2 の要否が変わるのか

3相瞬時電力は

$$
p \;=\; v_a i_a + v_b i_b + v_c i_c
$$

クラーク変換後の内積 $v_\alpha i_\alpha + v_\beta i_\beta$ との関係が、正規化（スケーリング）の違いでこう変わります：

* **振幅不変**：

  $$
  p \;=\; \tfrac{3}{2}\,(v_\alpha i_\alpha + v_\beta i_\beta)
  $$
* **電力不変**：

  $$
  p \;=\; v_\alpha i_\alpha + v_\beta i_\beta
  $$

パーク変換は**回転のみ（直交回転）**なので、この関係は $dq$ でもそのまま成り立ちます。
したがってベクトルの大きさで書く $P=\lVert \mathbf V\rVert \lVert \mathbf I\rVert \cos\theta$ も、上と**同じ係数**が付きます。

---

## $\lVert \mathbf I\rVert$ のスケール感（確認用）

正弦定常・平衡3相（相電流の実効値を $I_{\text{rms}}$）のとき：

* **電力不変**では

  $$
  \lVert \mathbf I\rVert \;=\; \sqrt{3}\;I_{\text{rms}},\qquad
  \lVert \mathbf V\rVert \;=\; \sqrt{3}\;V_{\text{rms}}
  $$

  よって

  $$
  P \;=\; (\sqrt{3}V_{\text{rms}})(\sqrt{3}I_{\text{rms}})\cos\theta
  \;=\; 3\,V_{\text{rms}} I_{\text{rms}}\cos\theta
  $$

  ときれいに一致（追加係数は不要）。

* **振幅不変**では $\alpha\beta$ ノルムが大きめに出るため、**外側に $\tfrac{3}{2}$** を掛けることで同じ三相電力に一致します。

---

## まとめ（もう一度）

* **電力不変**：$P=\lVert \mathbf V\rVert\lVert \mathbf I\rVert\cos\theta$（**3/2不要**）
* **振幅不変**：$P=\tfrac{3}{2}\lVert \mathbf V\rVert\lVert \mathbf I\rVert\cos\theta$（**3/2必要**）

同じ「$P=|\!V\!||\!I\!|\cos\theta$」でも、**どのクラーク正規化で作った$|\!V\!|,|\!I\!|$** かで 3/2 の要否が決まります。
