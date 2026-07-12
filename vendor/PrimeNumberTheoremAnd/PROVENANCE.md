# Provenance of the vendored `PrimeNumberTheoremAnd`

The code in this directory is a **vendored, trimmed copy** of the community
project *PrimeNumberTheoremAnd*:

* Upstream: https://github.com/AlexKontorovich/PrimeNumberTheoremAnd

## License

The vendored source files are copied verbatim from upstream. The upstream
project is released under the **Apache License 2.0**; where present, the original
per-file license headers are retained unchanged (e.g. `Auxiliary.lean` carries
"Copyright (c) 2024 Michael Stoll ... Released under Apache 2.0 license as
described in the file LICENSE"). Some upstream files carry no per-file header;
those too are copied verbatim. A copy of the Apache License 2.0 text is included
alongside this file as `LICENSE`. Authorship is credited to the upstream authors
(e.g. Michael Stoll, Alex Kontorovich, and other contributors); refer to the
upstream repository for the complete list of authors and any `NOTICE` file.

## What was kept

To keep this repository free of unused `sorry`-containing files, only the
transitive import closure of `PrimeNumberTheoremAnd.MediumPNT` is vendored here
(13 modules). This closure is `sorry`-free; the axiom audit in
`RequestProject/AxiomCheck.lean` certifies that the theorem `MediumPNT` — and
hence `Erdos768.erdos_768`, which depends on it — uses only the standard axioms
`propext`, `Classical.choice`, and `Quot.sound`.

The files removed relative to upstream are the modules that lie outside this
closure (they are not imported by `MediumPNT` and were never compiled by this
project). The Lean source files inside the closure are vendored **byte-for-byte
unmodified**: no definition, theorem, proof, or diagnostic line was added or
changed. The axiom certificate for `MediumPNT` is printed from the project's own
`RequestProject/AxiomCheck.lean`, not from the vendored source.
