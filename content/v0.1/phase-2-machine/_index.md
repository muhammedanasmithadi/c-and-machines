+++
title = "Machine Language"
description = "Phase 2 reads one C function in two dialects, x86-64 and AArch64, down to the bytes."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64 · QEMU 10.2.2 AArch64"
entry = "02"
order = 2
+++

Three modules, one law each. Read them in order: the two dialects, then the frame, then the bytes.

1. [Module 2A](@/v0.1/phase-2-machine/2a-two-dialects/index.md): the listing is what runs, not the C source. One function, two instruction sets, one job table.
2. [Module 2B](@/v0.1/phase-2-machine/2b-frames/index.md): the object lives between the setup line and the teardown line. Where Phase 1's `local` ended, on the page with the lines.
3. [Module 2C](@/v0.1/phase-2-machine/2c-bytes/index.md): every instruction is a number, and the bytes are the program. Endianness lives here, next to the word it orders.

Each module opens with a program, runs it, shows the mechanism, states its law in one sentence, and closes with practice: retrieve the law, complete a worked example, transfer to one new case.
