+++
title = "C and Machines"
description = "From first byte to complex systems. A self-paced course in C and the computer underneath it, taught from primary sources and proven against the machine."
+++

A program is a set of promises. You promise the machine that your pointers point to live objects, that your arrays stay in bounds, that memory is returned exactly once. The machine keeps no record of your promises; it keeps only their consequences. Break one, and the program may crash, print garbage — or print the right answer, with the debt still on the books. This book is the practice of auditing those promises before they default: the standard as contract, the code as evidence, the machine's own log as verdict.

The goal is plain. By the last phase you will write, alone, substantial programs: a shell that schedules jobs, an allocator a production service can trust, a concurrent server that survives its own load, an emulator that runs real machine code. Each is a small set of ideas, verified the plain way: run the code and read what it reports, in private, where a failure costs nothing.

Along the way you see what a machine actually is. Bits become bytes, then registers, stacks, caches, pages, processes, signals, networks. Each has budgets and failure modes, governed by a small number of laws you will meet again in every phase.

This is a textbook written as an apprenticeship. Nothing rests on the author's word. Each module opens with a concrete program or a real question, runs it, shows the mechanism underneath, then proves the claim three ways: the specification, the runnable code, and the machine's own log. Reproduce it on your machine, and the book becomes something you can check for yourself.

## How the course is built

Eight phases carry you from the first byte to working systems. Each phase ends with an artifact you build: proof of what you now understand, ready to survive an interview or a code review.

| Phase | Territory | Exit artifact |
|---|---|---|
| 0 | Bits, numbers, the C toolchain, the shell | Build a C program by hand, byte by byte |
| [1](@/v0.1/phase-1-pointers/index.md) | C mastery: pointers, memory, build systems | Clean, leak-free C under ASan + Valgrind |
| 2 | Machine language, x86-64 and AArch64 | Read any disassembly; translate C to both ISAs |
| 3 | Processor, optimizing, memory hierarchy | Measure and explain your own program's cache behavior |
| 4 | Linking, virtual memory, allocators | A `malloc` package that passes stress |
| 5 | Processes, signals, I/O, concurrency, networks | A shell with jobs; a concurrent Tiny server |
| 6 | Compilers and object files | From C to relocation and back |
| 7 | Capstones | Shell + malloc + server + emulator; stretch: a compiler |

In v0.1, only Phase 1 is written; its row links to the chapter. The remaining rows are the road ahead.

Every module follows one shape, held to a fixed standard:

1. **A concrete artifact opens it.** A real program or a real question you recognize at once.
2. **It runs.** Run it as-is; see the outcome as it is. A failure here is evidence.
3. **The mechanism comes next.** How the machine actually behaves: the registers, the storage durations, the allocator's ledger.
4. **A law lands in one sharp sentence.** The rule, stated so it can be repeated from memory.
5. **Proof has three parts.** The specification, the runnable code, the log. All three appear; you can check all three.
6. **Practice closes it.** The lab, its acceptance tests, and a pointer toward what comes next.

## How to read

- **Local first.** Run `zola serve` and open the URL it prints. Handwriting in the margins is encouraged.
- **You own the tools.** The build is one static binary; there is no framework between you and the prose. Read the source when you want to understand the book itself.
- **Reproduce everything.** Every trace in this course comes from a real run on Fedora 44, x86-64, with the ARM path via QEMU. If your machine says otherwise, your machine is the truth. Find out why.
- **Versions are frozen, not forgotten.** Snapshots live under `content/v0.x/`, each recorded with a `jj bookmark`. Every module's dateline names the edition and the reference build it was checked against.

## Source canon

This book teaches from primary sources, not summaries of them. When a paragraph rests on a reference, you are told which one and why. Two gates admit a source. Primary gate: the artifact itself (a standard, a measurement) from the person who made it. Public gate: two or more independent university adoptions, or sustained technical praise with specifics — never popularity.

- Kernighan & Ritchie, [*The C Programming Language*](https://9p.io/cm/cs/cbook/), 2e
- Bryant & O'Hallaron, [*Computer Systems: A Programmer's Perspective*](https://csapp.cs.cmu.edu/), 3e (CS:APP)
- Patterson & Hennessy, [*Computer Organization and Design*](http://booksite.elsevier.com/9780128017333/), ARM edition; *Computer Architecture*, RISC-V edition
- Stevens & Rago, *Advanced Programming in the UNIX Environment*, 3e
- Kerrisk, *The Linux Programming Interface*
- Tanenbaum & Bos, *Modern Operating Systems*
- Ritchie, [The Development of the C Language](https://www.bell-labs.com/usr/dmr/www/chist.html) (HOPL-II, 1993)
- Drepper, [What Every Programmer Should Know About Memory](https://lwn.net/Articles/250967/)
- Wilson et al., [Dynamic Storage Allocation: A Survey and Critical Review](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf)
- Intel SDM, ARM Architecture Reference Manual, RISC-V specs

High-quality practitioner writing is admitted case by case, against the same two-gate rule, and cited as what it is.

## Begin

Start at [Phase 1](@/v0.1/phase-1-pointers/index.md) (the only phase written so far). It needs no prerequisites beyond a machine and curiosity. Phase 0 (bits, numbers, toolchain, shell) is next in the writing order; the rest of the book is built out of exactly those, one promise at a time.