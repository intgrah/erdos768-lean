# Erdős Problem 768 — status of a full, unconditional discharge

This note answers the question: *what remains before the Lean proof of Erdős
Problem 768 is fully unconditional (no `sorry`, only the standard axioms)?*

## Short answer

**Nothing mathematical remains. The proof is complete and unconditional.**

The main theorem `Erdos768.erdos_768` in `RequestProject/Main.lean` is proved
with no `sorry` anywhere in its dependency graph, and

```
#print axioms Erdos768.erdos_768
-- 'Erdos768.erdos_768' depends on axioms:
--   [propext, Classical.choice, Quot.sound]
```

i.e. only the three standard Lean/Mathlib axioms — **no `sorryAx`, no custom
axioms, no `@[implemented_by]`**. The same holds for every intermediate result
(large sieve, subset-product moment, canonical compression, the two headline
bounds, and the prime-number-theorem input).

This was verified after a full `lake build RequestProject` (8064 jobs, no errors).

## What "was needed" — the full history in one place

Earlier notes in this repository described the situation while the proof was
still being assembled. For completeness, here is how each of the paper's genuinely
deep inputs is now discharged, all from scratch and all using only the standard
axioms:

1. **Bombieri–Davenport multiplicative large sieve** (Theorem 2.6):
   built in `RequestProject/LargeSieve.lean` (Gallagher's additive large sieve
   via a Sobolev/sampling inequality and Parseval) and
   `RequestProject/LargeSieveMult.lean` (reduction to the additive form via Farey
   spacing, the Gauss-sum norm `‖τ(χ)‖² = q`, and Dirichlet-character
   orthogonality).

2. **Subset-product second moment** (Lemma 3.1):
   `subset_product_hits_identity` in `RequestProject/SubsetProduct.lean`, with the
   counting forms in `RequestProject/SubsetProductCount.lean`.

3. **Reconstruction / weighted-prefix "canonical compression"** (Propositions
   8.5 & 9.2): `canonical_compression_exists`, built in
   `RequestProject/Compression.lean` and `RequestProject/Canonical.lean`.

4. **Prime number theorem in short logarithmic intervals** (Lemma 2.8):
   `primes_in_log_interval`, proved in `RequestProject/PNT.lean`. This was the
   last input to be discharged; see the next section.

The elementary Sections 2, 5, 6, 9, 10 reductions (`lower_bound`,
`lower_bound_subsequence`, `fourth_moment_cleaning`, `upper_bound`,
`regular_bound`, `irregular_bound`, and all the Section-2 moment/radical
estimates) are likewise fully proved. See `README.md` for the per-lemma map.

## How Lemma 2.8 (the analytic input) was discharged

The paper reduces Lemma 2.8 to the prime number theorem with a power-saving error
term. `RequestProject/PNT.lean` implements exactly this reduction in two layers:

* **Layer A — the elementary reduction** (`count_eq_primeCounting_diff`,
  `main_term_ratio_tendsto`, `error_over_denom_tendsto`,
  `primes_in_log_interval_proof`): given an error-term PNT for `π − li`, the
  logarithmic-interval count follows by real analysis (a main-term integral
  estimate on `1/log t`, plus checking the error is `o(δ·e^u/u)` for
  `δ ≥ u^{-2}`).

* **Layer B — the analytic input** (`pnt_li_error`): the error-term PNT itself.
  It is **derived from `MediumPNT`** — the prime number theorem for the Chebyshev
  `ψ` function with power-saving error, taken from the community
  `PrimeNumberTheoremAnd` project, which is vendored (only the `MediumPNT`
  dependency closure) under `vendor/PrimeNumberTheoremAnd`. The passage
  `ψ → θ → π → li` uses the elementary Chebyshev machinery in
  `Mathlib.NumberTheory.Chebyshev`.

`MediumPNT` and its entire 13-module import closure inside `PrimeNumberTheoremAnd`
are `sorry`-free (the many `sorry`s elsewhere in that project are in files **not**
imported by `MediumPNT`, and are never reached). The axiom check on
`erdos_768` above is the ground truth confirming this: nothing in the final proof
depends on any `sorry`.

### One faithfulness detail (does not affect unconditionality)

The paper writes the error-term PNT with the de la Vallée Poussin exponent,
`π(y) = li(y) + O(y·e^{-c√(log y)})`. The strongest error-term PNT currently
available in formalised form is the *medium*-strength one with exponent
`(log y)^{1/10}` (via `MediumPNT`), so the internal lemma `pnt_li_error` records
that weaker exponent. This is a strictly weaker statement than the paper's, and it
is **more than sufficient** for the Erdős-768 argument: the denominator in
Layer A is only polynomial in `log y`, so any fixed positive power of `log y` in
the exponent works. The final theorem `erdos_768` is stated exactly as in the
paper (see below) and is proved unconditionally using this input. This is
documented in the docstring of `RequestProject/PNT.lean`.

## The main theorem is faithful to the paper

`Erdos768.erdos_768` states, with no hypotheses,

```
lim_{x→∞}  log(x / A(x)) / (√(log x) · log log x)  =  1 / (2√(log 2)),
```

where `A(x) = #{ n ≤ x : SylowDivisor n }` and `SylowDivisor n` is: for every
prime `p ∣ n` there is a divisor `d ∣ n` with `d > 1` and `d ≡ 1 (mod p)`. This
matches the paper's definition (§1) and its main theorem verbatim.

## Building and reproducing the check

The vendored dependencies are wired in through `lakefile.toml` /
`lake-manifest.json`, on top of the prebuilt Mathlib. To reproduce:

```
lake build RequestProject
```

Then, in any file importing `RequestProject.Main`,
`#print axioms Erdos768.erdos_768` reports only
`propext`, `Classical.choice`, `Quot.sound`.

## Summary

* **0 `sorry` remain** in `RequestProject`.
* `erdos_768` depends only on the standard axioms — it is **fully unconditional**.
* All four deep inputs (large sieve, subset-product moment, canonical
  compression, error-term PNT) are proved; the last is obtained from the vendored,
  `sorry`-free `MediumPNT`.
