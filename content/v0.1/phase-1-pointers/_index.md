+++
title = "Pointers and Lifetime"
description = "Phase 1 explains storage duration, why a returned address can be invalid, and how to prove the fix with spec, code, and log."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
entry = "01"
order = 1
+++

Three modules, one law each. Read them in order: the live case, then the boundary, then the ledger.

1. [Module 1A](@/v0.1/phase-1-pointers/1a-address/index.md): a pointer is valid only while the object it names is alive. A safe program that obeys the rule.

2. [Module 1B](@/v0.1/phase-1-pointers/1b-lifetime/index.md): when the block exits, the automatic object's lifetime ends and the pointer's value becomes indeterminate. The same program with the owner gone.

3. [Module 1C](@/v0.1/phase-1-pointers/1c-allocator/index.md): the ledger has one owner per block, and `free` is how you tell it. The heap, the three bugs, and the tools that catch them.

Each module opens with a program, runs it, shows the mechanism, states its law in one sentence, and closes with practice: retrieve the law, complete a worked example, transfer to one new case.
