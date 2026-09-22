# C and Machines

A self-paced course from first byte to complex systems, in C and on the metal.
You read it as a static site and prove every claim on your own machine.

## Read

- Install Zola (the 0.23.x series builds this book cleanly).
- Run `make serve` (or `zola serve`) and open the URL it prints.

## Prove

- Lab gate for Phase 1: `make check` (ASan binaries fail as documented; fixed prints `fixed: 42`).
- Prose gate: `make preflight` (banned-word check from WRITING.md).
- Full site build: `make build`.

## Write

- `WRITING.md` holds the style contract (classic style with a teaching voice). Read it before you touch prose.
- Every trace in the book comes from a real run on Fedora 44, x86-64, with the ARM leg under QEMU. If your machine says otherwise, your machine is the truth — find out why.

## Versions

- Editions live under `content/v0.x/`, each recorded with a `jj` bookmark. Every module's dateline names the edition and the reference build it was checked against.
- `base_url` in `config.toml` is `/`, so builds emit root-relative links. Set a real host (sitemap, robots, absolute links) before you publish.

## Sources

- The full source canon lives on the home page. The footer names the short canon.
- Fonts: see `static/fonts/ATTRIBUTION.md`.
