# Changelog

## v0.1 — Pointers and Memory

2026-09-15

First frozen version. Covers Phase 1 pointers and memory.

### Revision: writing style and UI

Replaces the disease/cure rhetorical frame with the classic style: concrete
first, mechanism before law, one analogy at most (spec-true only), plain
vocabulary, no personification. Chapter renamed to "Pointers and Lifetime".
UI restyled to the "bound technical manual" design: ET Book (MIT) serif for
prose, JetBrains Mono (OFL) for machine voice, editorial red accent, warm
off-white paper, radius-0 across, single-column with a right margin rail for
sidenotes. Home page, chapter, and lab gate all verified.

### Revision: verdigris accent and front-matter writing pass

The editorial accent moves from red to verdigris (copper patina), and its
distribution quiets: accent now speaks only where the machine state speaks —
kicker, active tab, push buttons, allocator wash, proof rules, code labels,
ledger caption, focus outlines, version badge, verdict colors. Headings,
links, table headers, inline code, and rules return to ink. Verdict colors:
pass is deep leaf green, fail is oxide umber (brown, never red). Dark mode
inverts the accent luminances to hold contrast on dark paper.

### Revision: brass palette and prose hardening

The accent moves from verdigris to warm brass, and the paper from off-white to
cream: paper #f7f4ec, raised #f1ece0, ink #1f1d18; accent ramp runs
b07f2a → 4e3710, with accent-600 darkened to #82601c so all text use holds
5.25:1. Dark mode inverts to warm brass luminances. The machine surfaces
(proof, tabs, drawers, code blocks) get a soft drop shadow so raised elements
read as layered; prose stays flat. Home page and chapter prose hardened to
the WRITING.md standard: personification of the machine removed, analogy
stacks trimmed to one spec-true analogy per argument, flourishes cut. All
light and dark token pairs pass WCAG 4.5:1.

Home page rewritten as real front matter: a concrete opening, the plain goal
(write complex software alone), how the course and its modules are built, how
to read, and the source canon. Chapter prose lightly polished. A WRITING.md
style guide records the book's prose standard and fixes that the abbreviated
reply style of chat does not govern it. All themes verified in Firefox.

### Revision: warm greige + rust palette, vertical centering, verified logs

The palette moves from brass to warm greige with a rust accent. Light paper
#f2efe9, ink #2a2722, accent ramp b07f2a → rust (500 #8c5f3d, 600 #8d5a3f,
700 #71482f); dark mode inverts to warm luminances (accent 500 #ab754a,
600 #c08250, 700 #d49460), fixing the earlier dark-mode tokens that still
carried the old brass/olive reads. Text use of every token pair holds WCAG
4.5:1 in both schemes, verified by measured luminance. Ragged-right prose
column now centers at 40rem (margin-inline auto) with sidenotes riding the
outer rail, verified at 1280px and 375px.

Content audit complete (17 findings, all resolved). The chapter's proof logs
are now verbatim AddressSanitizer/LeakSanitizer output from GCC 16.2.1 and
Valgrind 3.27.1 on Fedora 44 x86-64, captured 2026-09-16: the leak, the
double-free, and the dangling case that GCC 16 folds to the NULL dereference
UBSan/ASan both record. The machine-view tabs carry genuine clang 22.1.8
assembly for x86-64 and AArch64. The C citation for indeterminate pointer
values corrected to 6.2.4p2 (7.22.3.3 is `realloc`, not `free`). Prose
hardening: personification cut, wall-of-claims trimmed, the allocator's
split/coalesce walk now matches the stepper's actual free order. New lab
binary `labs/malloc/tests/epilogue.c` reproduces the chapter's opening UB,
added to the Makefile as a build-only target. WRITING.md gains the epigraph
exception (rule stated first, proved below).

### Revision: QA audit of the flagship chapter (14 findings, all resolved)

An independent review pass over the chapter against its own artifacts. The
dangling-verdict label corrected: the chapter's dangling test is a NULL-fold,
not a heap-use-after-free, so the tool verdict reads `dangling detected`
previously `use-after-free detected`, and the three-failure table's belief
cell reworded to "Object outlives its use". The `-O0` optimizer dispute
settled by running the machine: GCC 16.2.1 folds `&local` to NULL at both
`-O0` and `-O2` (captured disassembly in the chapter), so the prose says
"the compiler", not "the optimizer"; clang 22 keeps the literal address at
both levels. The mechanism sections ("What the machine does with it", "The
heap, step by step") now precede "Proof in three parts", matching the
concrete-then-proof order. The Patterson & Hennessy citation softened to
chapter level, since the resource does not publish section-level TOCs. The
Wilson/Drepper sidenote no longer attributes the whole ledger to one
strategy; it names segregated free lists as one strategy and phase 9 as the
consumers. One analogy remains (the ledger); the tenant/deed, bookkeeping,
and static-buys flourishes removed. Path references made specific (`tests/`
for the four programs). "in the reader's own words" changed to the
epigraph's own words; "never freeing anything twice" dropped so the closing
does not misstate register handling.

### What ships

- Course map with all 8 phases outlined
- Phase 1 flagship chapter: "Pointers and Lifetime"
  - Concrete opening: predict the output, then run with two optimizer levels
  - Explains storage duration and lifetime from the C standard (6.2.4, 7.22.3)
  - Three lifetime failures: use after free, double free, leak — each with its cost
  - Proof triple: C11 spec, runnable C, AddressSanitizer log
  - Corrected interactive heap stepper: split and coalesce on `malloc`/`free`
  - Machine view: x86-64 and AArch64 tabs for the same returned-address code
  - Reading map: K&R Ch 5-6, CS:APP 9.9, Wilson survey, Drepper
  - AArch64 arms: QEMU user-mode, AAPCS64 call convention
- Labs: `labs/malloc/` with 5 C files (leak, doublefree, dangling, fixed, epilogue), Makefile, ASan gate, ARM cross notes
- Book: Zola 0.23.6 static site, local-first, vanilla JS under 50KB, clean technical light theme, single column

### Known v0.1 limitations

- Interactivity is tabs + memory stepper only; WASM steppers deferred to v0.2
- Version dropdown requires manual folder copy + jj bookmark; automation deferred