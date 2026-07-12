# `Erdos768.primes_in_log_interval` (Lemma 2.8) — DISCHARGED

This note records the (now complete) discharge of
`Erdos768.primes_in_log_interval`, the paper's Lemma 2.8 ("primes in logarithmic
intervals"). It is fully proved, and the whole project builds with no `sorry`;
`#print axioms Erdos768.erdos_768` reports only `propext`, `Classical.choice`,
`Quot.sound`.

## Structure of the proof (`RequestProject/PNT.lean`)

The proof follows the paper's two layers.

* **Layer A — the elementary reduction — fully proved.**
  Given the prime number theorem with a power-saving error term, Lemma 2.8
  follows by elementary real analysis:
  * `Erdos768.count_eq_primeCounting_diff` — the combinatorial identity
    `#{p prime : e^{u-δ} < p ≤ e^u} = π(⌊e^u⌋) - π(⌊e^{u-δ}⌋)`.
  * `Erdos768.main_term_ratio_tendsto` — the main-term estimate
    `(li2(e^u) - li2(e^{u-δ})) / ((1-e^{-δ})e^u/u) → 1`, via the two-sided bound
    `1/log t ∈ [1/u, 1/(u-δ)]` on `∫_{e^{u-δ}}^{e^u} dt/log t`.
  * `Erdos768.error_over_denom_tendsto` — the PNT error contribution divided by
    the denominator tends to `0` (the error beats every power of `u`, while the
    denominator is `≥ e^u/(2u³)` because `δ ≥ u^{-2}`).
  * `Erdos768.primes_in_log_interval_proof` — assembles the three into Lemma 2.8.

  `Erdos768.primes_in_log_interval` in `RequestProject/Analytic.lean` is proved by
  applying `primes_in_log_interval_proof`.

* **Layer B — the analytic input — fully proved** as `Erdos768.pnt_li_error`.
  It is derived from `MediumPNT` (the prime number theorem for the Chebyshev `ψ`
  function with power-saving error `O(x·e^{-c(log x)^{1/10}})`), taken from the
  community `PrimeNumberTheoremAnd` project and vendored — restricted to the
  `MediumPNT` dependency closure — under `vendor/PrimeNumberTheoremAnd`. The
  passage `ψ → θ → π → li` uses `Mathlib.NumberTheory.Chebyshev`
  (`abs_psi_sub_theta_le_sqrt_mul_log`,
  `primeCounting_eq_theta_div_log_add_integral`, …), decomposed into bridge
  lemmas that are all proved: `θ` inherits `ψ`'s error term; an
  integration-by-parts identity for `li`; the exact `π − li` formula in terms of
  `θ − id`; and a power-saving estimate of the error integral (split at `√x`).

## Note on the error exponent

The paper states the error-term PNT with the de la Vallée Poussin exponent
`e^{-c√(log y)}`. The strongest error-term PNT available in formalised form is the
medium-strength one with exponent `(log y)^{1/10}` (via `MediumPNT`), so
`pnt_li_error` records that exponent. Any fixed positive power of `log y` in the
exponent is more than enough for Layer A (its denominator is only polynomial in
`log y`), so the final theorem `erdos_768` goes through unchanged and
`sorry`-free with the exact paper statement.

## Verification

`MediumPNT` and its entire 13-module import closure in `PrimeNumberTheoremAnd`
are `sorry`-free. (`PrimeNumberTheoremAnd` contains `sorry`s in other files, but
none are imported by `MediumPNT`.) The definitive check is the axiom trace on the
final theorem, which shows no `sorryAx`:

```
#print axioms Erdos768.erdos_768
-- [propext, Classical.choice, Quot.sound]
```
