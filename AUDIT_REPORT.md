# Independent Audit — Erdős Problem 768 formalisation

Date: 2026-07-11. This report records an independent, from-scratch re-check of the
whole repository (every file, a full clean build, axiom tracing, and a faithfulness
cross-check against the paper source `erdos768_source.tex`).

## Verdict: GOOD — it works.

The formalisation is complete and sound. The main theorem is the paper's exact
statement, it has no hypotheses (so it is not vacuous), it builds with zero errors
and zero warnings, and it depends only on the three standard Lean/Mathlib axioms.
One packaging bug that broke a fresh build was found and fixed (see below).

## What was checked

### 1. Build (full, from the committed sources)
`lake build` completes successfully: **8065/8065 jobs, 0 errors, 0 warnings**,
including the vendored `PrimeNumberTheoremAnd` and `LeanArchitect` packages.

### 2. Axioms / soundness
`#print axioms` (in `RequestProject/AxiomCheck.lean`) reports:
- `Erdos768.erdos_768` depends on axioms: `[propext, Classical.choice, Quot.sound]`
- `MediumPNT` depends on axioms: `[propext, Classical.choice, Quot.sound]`

No `sorryAx`, no `Lean.ofReduceBool` (i.e. no `native_decide`), no custom `axiom`,
and no `@[implemented_by]` anywhere in the dependency graph. A source-level grep
confirms there is **no `sorry`/`admit`** in any `RequestProject/*.lean` file or in
the vendored PNT `.lean` sources (the only occurrences of those words are in prose
comments). The two `axiom` lines in the vendored file
`PrimeNumberTheoremAnd/Tactic/AdditiveCombination.lean` are in an unused tactic-test
helper and are not in the dependency graph of `erdos_768` (confirmed by the axiom
trace above).

### 3. Faithfulness to the paper (`erdos768_source.tex`)
- **Sylow divisor condition** (`Erdos768.SylowDivisor`, `Defs.lean`): "for every
  prime `p ∣ n` there is a divisor `d ∣ n` with `d > 1` and `d ≡ 1 (mod p)`" —
  matches the paper's `eq:def-condition` verbatim, including `1 ∈ 𝒜` by vacuous truth.
- **Counting function** `A(x) = #{n ≤ x : n ∈ 𝒜}` (`Erdos768.Acount`): the filtered
  cardinality over `Finset.Icc 1 ⌊x⌋₊` — matches.
- **Constant** `c₀ = 1/(2√(log 2))` (`Erdos768.c₀`): matches the paper's constant.
- **Main theorem** `Erdos768.erdos_768`:
  `lim_{x→∞} log(x/A(x)) / (√(log x)·log log x) = 1/(2√(log 2))` — this is exactly
  the paper's Theorem 1.1 / `eq` on lines 90–91 and 132–133.

Because `erdos_768` carries no hypotheses and its statement is fixed and correct,
the intermediate lemmas cannot "cheat" by being vacuously true: if any were too
weak they simply could not close the top goal. The two headline inputs are
genuine, quantitative, and non-degenerate:
- `Erdos768.lower_bound` (paper Thm 5.3): eventually `A(x) ≥ x·exp(-(c₀+ε)·S(x))`,
  assembled from `lower_bound_subsequence` + negligible-gap interpolation.
- `Erdos768.upper_bound` (paper Thm 10.4): eventually `A(x) ≤ x·exp(-(c₀-ε)·S(x))`,
  assembled from `irregular_bound` + `regular_bound` (whose filters together cover
  all of 𝒜), themselves resting on `radical_defect_tail`, the multiplicative large
  sieve, subset-product moments, and canonical compression.

### 4. Known caveat (documented, does not affect the top statement)
The vendored analytic input (`MediumPNT`) supplies a PNT error term with exponent
`(log y)^{1/10}` rather than the paper's `√(log y)`. This is strictly weaker but
more than sufficient for the argument; the top theorem is proved unconditionally
from it.

## Issue found and fixed

**Stale `lake-manifest.json` (build-breaking).** As committed, the manifest was a
copy of Mathlib's own manifest: it listed `mathlib` as a `path` dependency and
omitted the two vendored `path` packages (`PrimeNumberTheoremAnd`, `LeanArchitect`)
required by `lakefile.toml`. A fresh `lake build` therefore failed to configure:

```
error: dependency 'PrimeNumberTheoremAnd' not in manifest; use `lake update ...`
```

Fix: regenerated the manifest with `lake update`, so it now matches `lakefile.toml`
(git dep on Mathlib pinned to `v4.28.0`, path deps on the two vendored packages).
After the fix the full build succeeds as reported above. This is the only change
made during this audit; no `.lean` sources were modified.
