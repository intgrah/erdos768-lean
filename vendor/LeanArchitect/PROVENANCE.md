# Provenance of the vendored `LeanArchitect`

The code in this directory is a **vendored copy** of the *LeanArchitect*
blueprint/tactic tooling:

* Upstream: https://github.com/hanwenzhu/LeanArchitect

It is included only because the vendored `PrimeNumberTheoremAnd` modules
(`import Architect`) depend on it for their blueprint annotations.

## License

LeanArchitect is released by its upstream author under the **Apache License
2.0**. A copy of that license text is included alongside this file as `LICENSE`.
The vendored `.lean` files are copied verbatim from the upstream revision
compatible with this project's toolchain (`leanprover/lean4:v4.28.0`); refer to
the upstream repository for authorship and any `NOTICE` file.

## A note on the textual occurrences of `sorry`

`grep` finds `sorry`/`sorryAx` in a few files here, but none of them are proof
holes:

* `Architect/Tactic.lean` defines a `sorry_using [...]` tactic — a variant of
  `sorry` that additionally records blueprint dependencies (framework code).
* `Architect/CollectUsed.lean` and `Architect/Output.lean` reference `sorryAx`
  in order to *detect and flag* proofs that are incomplete (`leanOk := !uses.contains sorryAx`).

No proof in the dependency graph of `Erdos768.erdos_768` invokes any of these,
as the axiom audit in `RequestProject/AxiomCheck.lean` certifies (the only axioms
are `propext`, `Classical.choice`, `Quot.sound`).
