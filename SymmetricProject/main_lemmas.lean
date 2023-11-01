import Mathlib.Analysis.SpecialFunctions.Pow.Real
import SymmetricProject.prev_bound
import SymmetricProject.Tactic.Rify
import SymmetricProject.Tactic.RwIneq

/- In this file the power notation will always mean the base and exponent are real numbers. -/
local macro_rules | `($x ^ $y)   => `(HPow.hPow ($x : ℝ) ($y : ℝ))

/- In this file the division  notation will always mean division of real numbers. -/
local macro_rules | `($x / $y)   => `(HDiv.hDiv ($x : ℝ) ($y : ℝ))

/- In this file, inversion will always mean inversion of real numbers. -/
local macro_rules | `($x ⁻¹)   => `(Inv.inv ($x : ℝ))

/- The purpose of this file is to prove some easy lemmas used in the main arguments
-/

open Real

/-- If a ≤ bc and dc ≤ e then ad ≤ bc.  Sort of an le_trans with multiplicative factors. --/
lemma lem0 {a b c d e : ℝ} (h1: a ≤ b * c) (h2: d * c ≤ e) (h3 : 0 ≤ d) (h4 : 0 ≤ b): a * d ≤ b * e := by
  replace h1 := mul_le_mul_of_nonneg_right h1 h3
  replace h2 := mul_le_mul_of_nonneg_left h2 h4
  linarith

/-- A specific rearrangement of a quadruple product that was a bit complicated to do directly from mul_comm and mul_assoc. --/
lemma lem1 {a b c d: ℝ} : (a*b)*(c*d)= (b*d) * (a*c) := by ring

/-- A version of div_le_iff where we use a * c⁻¹ instead of a/c.  --/
lemma lem2 {a b c : ℝ} (h: c>0) : a ≤ b*c ↔ a * c⁻¹ ≤ b := by
  constructor
  . intro this
    rw [<- div_le_iff h] at this
    convert this using 1
  intro this
  rw [<- div_le_iff h]
  convert this using 1

/-- A version of le_div_iff where we use b * c⁻¹ instead of b/c.  --/
lemma lem3 {a b c : ℝ} (h: c>0) : c*a ≤ b ↔ a ≤ b * c⁻¹ := by
  constructor
  . intro this
    rw [<- le_div_iff' h] at this
    convert this using 1
  intro this
  rw [<- le_div_iff' h]
  convert this using 1

/-- a^b ≤ c iff a ≤ c^{b⁻¹}.  --/
lemma lem4 {a b c : ℝ} (ha: 0 ≤ a) (hb : 0 < b) (h: a^b ≤ c) : a ≤ c^b⁻¹ := by
  replace h := rpow_le_rpow (by positivity) h (show 0 ≤ b⁻¹ by positivity)
  convert h using 1
  rw [<- rpow_mul ha, mul_inv_cancel (by positivity)]
  simp


/-- If 1 ≤ N then e^(1/N) ≤ e -/
lemma lem5 {N : ℕ} (h : 1 ≤ N) : rexp N⁻¹ ≤ rexp 1 := by
  rify at h
  have : (0:ℝ) < N := by linarith
  gcongr
  rw [inv_le this]
  simpa; norm_num

/-- the main calculation needed to handle the bounded k case. -/
lemma lem6 {n k N : ℕ} {C s A : ℝ} (h1 : 1 ≤ C * n^2⁻¹ * |s|^k⁻¹) (h2: (n/k)^2⁻¹ * |s|^k⁻¹ ≤ A⁻¹ * rexp N⁻¹) (hA: 0 < A) (hk : 0 < k) (hN: 1 ≤ N) : A ≤ k^2⁻¹ * C * rexp 1 := by
  have hn : 0 < n := by
    contrapose! h1
    replace h1 := (show n = 0 by linarith)
    simp [h1]
  have hC : 0 < C := by
    contrapose! h1
    have := mul_nonpos_of_nonpos_of_nonneg h1 (show 0 ≤ n^2⁻¹ by positivity)
    have := mul_nonpos_of_nonpos_of_nonneg this (show 0 ≤ |s|^k⁻¹ by positivity)
    linarith
  have h3 : A⁻¹ * rexp N⁻¹ ≤ A⁻¹ * rexp 1 := mul_le_mul_of_nonneg_left (lem5 hN) (show 0 ≤ A⁻¹ by positivity)
  replace h2 := h2.trans h3
  have bound := lem0 h1 h2 (by positivity) (by positivity)
  rw [mul_comm A⁻¹ _, <- mul_assoc, <- lem3 (by positivity), one_mul, <-le_div_iff (by positivity)] at bound
  convert bound using 1
  rw [div_rpow, div_div_eq_mul_div]
  field_simp [hk,hn]
  ring
  all_goals positivity

lemma lem7a { a b c d : ℝ } (h1: a ≤ c) (h2: b ≤ d) (h3: 1 ≤ a) (h4: 0 ≤ b) : a^b ≤ c^d := by
  have : a^b ≤ a^d := rpow_le_rpow_of_exponent_le h3 h2
  apply this.trans
  exact rpow_le_rpow (by linarith) h1 (by linarith)

/-- The main calculation needed to handle the k > 2n/3 case. -/
lemma lem7 {n k N : ℕ} {A : ℝ} (h1 : k ≥ 10) (h2 : k+1 ≤ n) (h3: 3*k ≥ 2*n) (hN: 1 ≤ N) (hA: 0 < A) (bound: 1*(n/k)^2⁻¹ ≤ A^(((n:ℝ)-k)/k) * (n/((n:ℝ)-k))^((n-k)/(2*k)) * (A⁻¹ * rexp N⁻¹)) : A ≤ (rexp (rexp 1)⁻¹ * rexp 1)^2 := by --placeholder
  have hk : k ≤ n := by linarith
  have hk' : 0 < k := by linarith
  have hk'': 0 < (k:ℝ) := by norm_cast
  have hn : 0 < n := by linarith
  have hn' : 0 < (n:ℝ) := by norm_cast
  have hkn : k/n ≤ 1 := by
    rw [div_le_iff]; norm_cast; simpa; positivity
  have hN' : rexp N⁻¹ ≤ rexp 1 := lem5 hN
  have h11: 0 < n - (k:ℝ) := by rify at h2; linarith
  have h12: ((n - (k:ℝ)) / k + -1) * (-1) = (2*(k:ℝ) - n) / k := by field_simp [hk'']; ring
  have h13: 0 < 2*(k:ℝ) - n := by rify at h1 h2 h3; linarith

  rw [lem1, <-rpow_neg_one A, <- rpow_add, lem2, one_mul, lem3, <- inv_rpow _ 2⁻¹, inv_div] at bound
  rw_ineq [hN', hkn] at bound
  rw [<- rpow_neg_one, <-rpow_mul] at bound
  rw [h12] at bound
  replace bound := lem4 (by positivity) (by positivity) bound
  apply bound.trans
  clear N hN hN' A hA bound h12
  apply lem7a
  . simp
    have h14 : (n - (k:ℝ)) / (2*k) = (n / (n-(k:ℝ)))⁻¹ * (n / (2*k)) := by
      rw [inv_div]
      field_simp [hn, hk', h11]
    rw [h14, rpow_mul]
    gcongr
    . rw [<- rpow_one (rexp (rexp 1)⁻¹) ]
      apply lem7a
      . exact root_self (by positivity)
      . rw [div_le_iff]; linarith; positivity
      . apply one_le_rpow
        . rw [le_div_iff]; linarith; positivity
        positivity
      positivity
    positivity
  . rw [inv_le, le_div_iff]; field_simp; rify at h1 h2 h3; linarith; all_goals positivity
  . simp
    nth_rewrite 1 [(show (1:ℝ)=(1:ℝ)*1 by norm_num)]
    gcongr
    . apply one_le_rpow
      . rw [le_div_iff]; linarith; positivity
      positivity
    exact one_le_exp (by norm_num)
  all_goals positivity
