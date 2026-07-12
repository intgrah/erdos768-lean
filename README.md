This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# Erdős Problem 768 — Lean formalisation

This project formalises Eric Li's paper *The Sylow Divisor Condition: a
Resolution of Erdős Problem 768* (arXiv:2606.24872). The paper's LaTeX source is
kept in `erdos768_source.tex` for reference.

## The problem and the main theorem

An integer `n` satisfies the **Sylow divisor condition** if for every prime
`p ∣ n` there is a divisor `d ∣ n` with `d > 1` and `d ≡ 1 (mod p)`. Writing
`A(x)` for the number of such `n ≤ x`, the main result is

```
lim_{x→∞}  log(x / A(x)) / (√(log x) · log log x)  =  1 / (2√(log 2)).
```

This is stated (and reduced to the two bounds) in `RequestProject/Main.lean` as
`Erdos768.erdos_768`.

## File structure

* `RequestProject/Defs.lean` — the Sylow divisor condition `SylowDivisor`, the
  set `Acal`, the counting function `Acount`, the constant `c₀ = 1/(2√log 2)`,
  the scale `S(x) = √(log x)·log log x`, the ordered `k`-fold divisor function
  `dk`, and auxiliaries `rad`, `sr`, `hr`.
* `RequestProject/Elementary.lean` — the elementary estimates of Section 2 (plus
  the one-bit valuation completion, Lemma 6.1) and the scalar optimisation.
* `RequestProject/Analytic.lean` — the analytic inputs of Sections 2–3
  (multiplicative large sieve, primes in logarithmic intervals, subset products).
* `RequestProject/PNT.lean` — the two-layer proof of Lemma 2.8 (primes in
  logarithmic intervals): the elementary reduction plus `pnt_li_error`, the
  error-term PNT for `π − li` derived from the vendored `MediumPNT`.
* `RequestProject/LargeSieve.lean` / `RequestProject/LargeSieveMult.lean` — the
  from-scratch proof of the Bombieri–Davenport multiplicative large sieve
  (Theorem 2.6): Gallagher's additive large sieve and its reduction to the
  multiplicative form.
* `RequestProject/Compression.lean` / `RequestProject/Canonical.lean` — the
  reconstruction / weighted-prefix "canonical compression" package (Propositions
  8.5 & 9.2), proving `canonical_compression_exists`.
* `RequestProject/SubsetProduct.lean` — the complete, self-contained proof of the
  subset-product second moment (Lemma 3.1), used by `Analytic.lean`.
* `RequestProject/SubsetProductCount.lean` — the counting form of the
  subset-product lemma (`subset_product_count` and its `Fintype`-indexed
  version), derived from `subset_product_hits_identity`.
* `RequestProject/LowerBound.lean` — the prime-layer construction, the
  fourth-moment cleaning, and the transfer of the subsequence bound to all `x`
  (Section 5).
* `RequestProject/LowerBoundCount.lean` — the counting core of the constructive
  lower bound: the cleaned layers `cleanLayer`, the subset-product counting
  argument, and `lower_bound_subsequence` (Theorem 5.3 along `x = e^{L_r}`).
* `RequestProject/UpperBound.lean` — the canonical compression / reconstruction
  package and the weighted-prefix bound (Sections 6–10).
* `RequestProject/Main.lean` — the two headline bounds and the main theorem.
* `RequestProject/AxiomCheck.lean` — the axiom audit (`#print axioms`) of the
  main theorem; see "Verifying soundness" below.

## Status

**The formalisation is complete and fully unconditional.** The main theorem
`Erdos768.erdos_768` is proved with no `sorry` anywhere in its dependency graph,
and depends only on the standard axioms:

```
#print axioms Erdos768.erdos_768
-- 'Erdos768.erdos_768' depends on axioms:
--   [propext, Classical.choice, Quot.sound]
```

There are no custom `axiom`s and no `@[implemented_by]` attributes. A full
`lake build RequestProject` completes with no errors.

All four of the paper's genuinely deep inputs are proved from scratch (each using
only `propext` / `Classical.choice` / `Quot.sound`):

* **`multiplicative_large_sieve`** (Theorem 2.6, Bombieri–Davenport large sieve)
  — `RequestProject/LargeSieve.lean` + `RequestProject/LargeSieveMult.lean`.
* **`subset_product_hits_identity`** (Lemma 3.1, subset-product second moment)
  — `RequestProject/SubsetProduct.lean` (counting forms in
  `RequestProject/SubsetProductCount.lean`).
* **`canonical_compression_exists`** (Propositions 8.5 & 9.2, reconstruction /
  weighted-prefix package) — `RequestProject/Compression.lean` +
  `RequestProject/Canonical.lean`.
* **`primes_in_log_interval`** (Lemma 2.8, PNT in short logarithmic intervals)
  — `RequestProject/PNT.lean`. Its analytic core `pnt_li_error` (the error-term
  PNT for `π − li`) is derived via `ψ → θ → π → li` from `MediumPNT`, the
  medium-strength prime number theorem of the community `PrimeNumberTheoremAnd`
  project, vendored (restricted to the `MediumPNT` dependency closure, which is
  `sorry`-free) under `vendor/PrimeNumberTheoremAnd`.

The elementary reductions of Sections 2, 5, 6, 9, 10 are likewise fully proved,
including `lower_bound` (Theorem 5.3), `lower_bound_subsequence`,
`fourth_moment_cleaning` (Lemma 5.1), `upper_bound` (Theorem 10.4),
`regular_bound`, `irregular_bound`, and all the Section-2 moment and radical
estimates (`dk_sum_le`, `local_moment`, `restricted_moment`, `omega_tail`,
`radical_defect_sum`, `radical_defect_tail`, …), together with the optimisation
`opt_lower` / `opt_attained` and the staircase sum `hr_sum_asymp`.

### A note on the error-term exponent

The paper states its analytic input with the de la Vallée Poussin exponent,
`π(y) = li(y) + O(y·e^{-c√(log y)})`. The strongest error-term PNT available in
formalised form is the medium-strength one with exponent `(log y)^{1/10}`, so the
internal lemma `pnt_li_error` records that (weaker) exponent. This is amply
sufficient for the Erdős-768 argument — the denominator in the Lemma 2.8
reduction is only polynomial in `log y`, so any fixed positive power of `log y`
suffices — and the headline theorem `erdos_768` is stated exactly as in the
paper. See `WHAT_IS_NEEDED.md` and the docstring of `RequestProject/PNT.lean`.

### Building

The project depends on Mathlib (pinned to `v4.28.0` in `lake-manifest.json`,
fetched from git) together with two vendored path dependencies under `vendor/`:

* `PrimeNumberTheoremAnd` — trimmed to the `MediumPNT` dependency closure (13
  modules), which is `sorry`-free; and
* `LeanArchitect` — the blueprint/tactic tooling that `MediumPNT` imports. (Its
  only textual occurrences of `sorry` are in its own metaprogramming: the
  definition of a `sorry_using` tactic and the `sorryAx`-detection used to *flag*
  incomplete proofs. No proof reaching `erdos_768` invokes them, as the axiom
  audit below certifies.)

From a fresh checkout with the matching toolchain (`lean-toolchain`,
`leanprover/lean4:v4.28.0`):

```
lake exe cache get      # fetch the prebuilt Mathlib oleans
lake build RequestProject
```

### Verifying soundness

`RequestProject/AxiomCheck.lean` is part of the default build target, so an
ordinary `lake build RequestProject` prints

```
'Erdos768.erdos_768' depends on axioms: [propext, Classical.choice, Quot.sound]
'MediumPNT' depends on axioms: [propext, Classical.choice, Quot.sound]
```

(The second line reports the axioms of the vendored analytic input on its own;
the vendored source is kept byte-for-byte unmodified, and this diagnostic lives
in `RequestProject/AxiomCheck.lean`.) Since `#print axioms` traces the whole
transitive dependency graph (including the vendored `MediumPNT`), this is a
complete machine-checked certificate that the formalisation is `sorry`-free and
unconditional.
