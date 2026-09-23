+++
title = "C and Machines"
description = "From first byte to complex systems. A self-paced course in C and the computer underneath it, taught from runnable programs and proven against the machine."
+++

This course teaches C by watching the machine. You will write small programs, run them, and read the files the compiler left behind. By the last phase you will have built a shell, an allocator, a concurrent server, and an emulator. Start at Phase 0. The first exercise takes ten minutes: compile twenty lines and name the four files `gcc` produced.

## How the course is built

Eight phases carry you from the first byte to working systems. Each phase ends with an artifact you build: proof of what you now understand, ready to hold up in an interview or a code review.

| Phase | Territory | Exit artifact |
|---|---|---|
| [0](@/v0.1/phase-0-toolchain/index.md) | Bits, numbers, the C toolchain, the shell | Build a C program by hand, stage by stage |
| [1](@/v0.1/phase-1-pointers/_index.md) | C mastery: pointers, memory, build systems | Clean, leak-free C under ASan + Valgrind |
| [2](@/v0.1/phase-2-machine/index.md) | Machine language, x86-64 and AArch64 | Read small disassemblies; translate C to both ISAs |
| 3 | Processor, optimizing, memory hierarchy | Measure and explain your program's cache behavior |
| 4 | Linking, virtual memory, allocators | A `malloc` package that passes stress |
| 5 | Processes, signals, I/O, concurrency, networks | A shell with jobs; a concurrent Tiny server |
| 6 | Compilers and object files | From C to relocation and back |
| 7 | Capstones | Shell + malloc + server + emulator; stretch: a compiler |

In v0.1, Phases 0, 1, and 2 are written; their rows link to the chapters. The remaining rows are the road ahead.

Every module follows one shape, held to a fixed standard:

1. **A concrete artifact opens it.** A real program or a real question you recognize at once.
2. **It runs.** Run it as-is; see the outcome as it is. A failure here is evidence.
3. **The mechanism comes next.** How the machine actually behaves: the registers, the storage durations, the allocator's ledger.
4. **A law lands in one sharp sentence.** The rule, stated so it can be repeated from memory.
5. **Proof has three parts.** The specification, the runnable code, the log. All three appear; you can check all three.
6. **Practice closes it.** The lab, its acceptance tests, and a pointer toward what comes next.

## Begin

Start at [Phase 0](@/v0.1/phase-0-toolchain/index.md) (the only prerequisites are a machine and curiosity). The first exercise takes ten minutes: compile `hello.c`, stop `gcc` at each stage, and name the four files it produced.

## How this book is made

This book is written as an apprenticeship. Each module opens with a concrete program or a real question, runs it, shows the mechanism underneath, then proves the claim three ways: the specification, the runnable code, and the machine's own log. Reproduce it on your machine, and the book becomes something you can check for yourself.

The goal is plain. By the last phase you will write, alone, substantial programs: a shell that schedules jobs, an allocator a production service can trust, a concurrent server that survives its own load, an emulator that runs real machine code. Each is a small set of ideas, verified the checkable way: run the code and read what it reports, in private, where a failure costs nothing.

Along the way you see what a machine actually is. Bits become bytes, then registers, stacks, caches, pages, processes, signals, networks. Each has budgets and failure modes, governed by a few laws you will meet again in every phase.

The full prose law lives in `WRITING.md`: concrete first, mechanism before law, the machine judges. One module teaches one law. Terms come before the model, a safe case comes before the bug, and the standard is quoted after the run, never as the first instruction.

Build notes, for returning readers: run `zola serve` and open the URL it prints. The build is one static binary; there is no framework between you and the prose. Every trace in this course comes from a real run on Fedora 44, x86-64, with the ARM path via QEMU. If your machine says otherwise, your machine is the truth. Find out why. Snapshots live under `content/v0.x/`, each recorded with a `jj bookmark`. Every module's dateline names the edition and the reference build it was checked against.

After Phase 1 you will have a precise version of this: a pointer is a promise that an object is still alive. The machine does not store the promise. If you break it, the C standard calls the behavior undefined — crash, garbage, or a lucky correct print.

## Source canon

This book teaches from primary sources, cited after the lab, not before it. When a paragraph rests on a reference, you are told which one and why.

**Read with this chapter** — one chapter, one section, why (one clause). Each module names its reading after the lab, under "Read after." You do not need the C standard yet. Phase 1 will quote two sentences from §6.2.4 after the dangling pointer has crashed.

**Shelf** — the rest, for later:

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
