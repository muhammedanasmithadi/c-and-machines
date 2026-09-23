+++
title = "1C — The allocator's ledger"
description = "Malloc, free, and the three ledger bugs, proven with sanitizers on two ISAs."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
entry = "01"
module_id = "1C"
law = "The ledger has one owner per block, and free is how you tell it."
pretrain = ["malloc", "free", "leak", "double free", "ledger"]
order = 3
+++

<div class="epigraph">
<p>The ledger has one owner per block, and <code>free</code> is how you tell it.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Module 1B had one bug: a pointer outliving its block. The heap adds two more, and both are bookkeeping failures. Every lifetime bug in this book is one of three:

1. **Use after free.** You read or write through a pointer after the object's lifetime has ended. Module 1B did this: `winner` returns `&local`, and `w->points` reads past the block's exit.
2. **Double free.** Two paths release the same block. The allocator's record for the block breaks, and the next `malloc` returns a block that two owners believe is theirs.
3. **Leak.** Memory you no longer need, never returned. Small in a test, unbounded in a server. Left running, the process grows until it exhausts its address space or meets the kernel's out-of-memory killer.

All three share a root cause: a mismatch between when you believe an object exists and when the storage is still yours to use.

| Bug | Belief | Machine's rule |
|---|---|---|
| Use after free | Object outlives its use | Lifetime ends; the value is indeterminate |
| Double free | It is safe to `free` twice | Each block is returned once; the second `free` is a stranger's call, even from the same hand |
| Leak | I will `free` it later | The allocator reclaims blocks only when told |

The three bugs charge different prices. A leak costs memory and time: resident memory (RSS) climbs as the allocator hands out new pages, and latency often follows. A double free costs correctness first: the allocator's record breaks, and a later `malloc` may hand the same block to a new owner while the old one still writes there. Use after free is the hardest to chase. The program prints the right answer on your laptop under one compiler, and the wrong answer on another machine from the same source.

The syntax in each case is correct. The mistake in each is a misjudged lifetime.

## The allocator's ledger

`malloc` manages the heap with a ledger. The ledger records every block: its address, its size, whether it is free. For the full mechanism, read [CS:APP §9.9](https://csapp.cs.cmu.edu/) and the [Wilson survey](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf). Both describe real allocators as this bookkeeping plus a search policy.

Three facts about the ledger explain the three bugs:

- `free(p)` removes your block from the ledger. From that moment, the block belongs to the allocator, not to you. Using `p` after `free` reads a block whose entry no longer has your name.
- A double free happens when two parts of a program each believe they own the block. The ledger is not designed for two owners.
- The allocator reclaims blocks only when told. A block you never free stays in the ledger, marked occupied, even if nothing references it. Read the three facts as three ledger rules, then walk them in the stepper below.

**The ledger has one owner per block, and `free` is how you tell it.** One owner means one `free`. Zero means a leak. Two means the record breaks.

## The heap, step by step

Walk the ledger yourself. Before each press, say which block the allocator must split or coalesce. Each press steps one `malloc` or `free` in the model and shows what the ledger records.

{% raw %}
<div class="memmap-stepper" data-memmap-step>
<button class="push-btn" data-labels="initial|malloc(8)|malloc(8)|malloc(32)|free a|free b|free c" style="margin-bottom:.6rem">step</button>
<div class="memmap">
  <div class="memmap-row" data-states="free,alloc,alloc,alloc,free,free,free" data-notes="one 48 B free block|a owns 8 B; 40 B free|a owns 8 B; 32 B free|a,b,c own all 48 B|a free; 8 B free|a,b free; 16 B free|one 48 B free block">
    <span class="memmap-addr">0x4000</span><span>a — 8 B</span><span class="memmap-note"></span>
  </div>
  <div class="memmap-row" data-states="free,free,alloc,alloc,alloc,free,free" data-notes="48 B free|40 B free after a|b owns 8 B; 32 B free|a,b,c own all 48 B|b owns 8 B; a free|a,b free; 16 B free|48 B free">
    <span class="memmap-addr">0x4008</span><span>b — 8 B</span><span class="memmap-note"></span>
  </div>
  <div class="memmap-row" data-states="free,free,free,alloc,alloc,alloc,free" data-notes="48 B free|40 B free|32 B free|a,b,c own all 48 B|32 B owned by c|32 B owned by c|48 B free, coalesced">
    <span class="memmap-addr">0x4010</span><span>c — 32 B</span><span class="memmap-note"></span>
  </div>
</div>
<div class="ledger-caption">one 48-byte block, three allocations, three frees, one coalescing, back to one free block</div>
</div>
{% endraw %}

Follow the chain: `malloc(8)` splits the free 48-byte block into an 8-byte occupant and a 40-byte remainder. The second `malloc(8)` splits again. `malloc(32)` takes the rest. Each free returns its block to the allocator's ledger. The final free coalesces the adjacent free blocks back into one 48-byte block the next `malloc` can use whole.

Watch what the sum does across all seven steps: it stays 48 bytes the whole time. Splits and coalescing change which block is occupied, never how much memory the ledger accounts for. An allocator must preserve that invariant. Each of the three bugs breaks it in its own way.

<aside class="sidenote"><a href="https://csapp.cs.cmu.edu/3e/docs/dsa.pdf">Wilson et al. (1995)</a> name segregated free lists as one allocator strategy; <a href="https://lwn.net/Articles/250967/">Drepper (2007)</a> explains why split and free cost is really a cache cost. Both are in the reading list. Phase 4 (allocation at scale) uses this vocabulary without further introduction.</aside>

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The lab for this lesson, <code>labs/malloc/</code>, holds four programs in <code>tests/</code>, one per failure mode plus the fix: <code>leak.c</code>, <code>doublefree.c</code>, <code>dangling.c</code>, <code>fixed.c</code>. Run each against the machine's own tools.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>The ledger rule is the contract. <code>doublefree.c</code> returns one block twice (lines 11–12), <code>leak.c</code> never returns its 40 bytes. The tools then show the proof. The dangling case was proven in <a href="@/v0.1/phase-1-pointers/1b-lifetime/index.md">1B</a>.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>This is the machine's answer. Under AddressSanitizer, each failure produces a trace that names the file, the line, and the cause.</p>
  </div>
</div>

```txt
$ ./build-asan/leak
==NNNN==ERROR: LeakSanitizer: detected memory leaks
Direct leak of 40 byte(s) in 1 object(s) allocated from:
    #1 0x0000004004e7 in main tests/leak.c:7
SUMMARY: AddressSanitizer: 40 byte(s) leaked in 1 allocation(s).

$ ./build-asan/doublefree
==NNNN==ERROR: AddressSanitizer: attempting double-free on 0x7ac...010 in thread T0:
    #1 0x0000004005c2 in main tests/doublefree.c:12
0x7ac...010 is located 0 bytes inside of 4-byte region [0x7ac...010,0x7ac...014)
freed by thread T0 here:
    #1 0x0000004005b6 in main tests/doublefree.c:11
previously allocated by thread T0 here:
    #1 0x0000004004f7 in main tests/doublefree.c:7
SUMMARY: AddressSanitizer: double-free tests/doublefree.c:12 in main
==NNNN==ABORTING

$ ./build-asan/fixed
fixed: 42

$ make -C labs/malloc check
VERIFIED ./build-asan/leak
VERIFIED ./build-asan/doublefree
VERIFIED ./build-asan/dangling
VERIFIED ./build-asan/fixed
```

Every line here is the machine's own. The `==NNNN==` masks the process id, which changes each run; the heap address `0x7ac...` changes with the allocator's state. Everything else is as the tools wrote it. The gate runs each binary and prints one VERIFIED line per program, shown last. Reference: GCC 16.2.1 with `-fsanitize=address,undefined`, Fedora 44, x86-64, 2026-09-16.

Each verdict needs its own reading. The leak exits 0, and an exit code of zero is not a pass. Only a tool that checks the ledger at exit sees the 40 bytes. `valgrind --leak-check=full` shows it plainly:

```txt
$ valgrind --leak-check=full ./build/leak
leak: phantom
==NNNN== HEAP SUMMARY:
==NNNN==     in use at exit: 40 bytes in 1 blocks
==NNNN== 40 bytes in 1 blocks are definitely lost in loss record 1 of 1
==NNNN==    at 0x4841AE6: malloc (vg_replace_malloc.c:447)
==NNNN==    by 0x400497: main (leak.c:7)
==NNNN== LEAK SUMMARY:
==NNNN==    definitely lost: 40 bytes in 1 blocks
==NNNN== ERROR SUMMARY: 1 errors from 1 contexts (suppressed: 0 from 0)
```

(The same masking applies.) Valgrind 3.27.1 needs no special build flags. It runs the plain `./build/leak` and watches what the program does from the outside.

The double-free is caught at the second `free`, exactly where the source breaks the rule. Run each binary by hand for the full stack, the register dump, and the exact heap addresses, unshortened.

## Practice

`labs/malloc/` holds `winner.c` (the 1B opening program), `leak.c`, `doublefree.c`, `dangling.c`, and `fixed.c`. Your work:

1. Close the page. Write the ledger law in one sentence. Write why a second `free` breaks the record even though the pointer is unchanged.
2. Build with `gcc -O0 -g -Wall -Wextra -std=c11` and run each binary. Note which fail and which pass *on the surface*.
3. Run `make -C labs/malloc check` and see each verdict against the ASan build.
4. Fix the three broken files so all three pass under ASan and Valgrind. For `dangling.c` the fix is the static-duration design; for `doublefree.c`, a `free` per `malloc`, one owner; for `leak.c`, the missing `free`.
5. (Stretch) Cross-build the same sources for AArch64 and run them under QEMU. Follow `labs/malloc/notes/arm.md`. The lesson must hold on the other ISA too.

Read after you finish, not before: K&R 2e ([the C book](https://9p.io/cm/cs/cbook/)), **Ch 5–6** for pointers and structures and Appendix A for storage classes (what each duration promises); CS:APP 3e **§9.9** for dynamic allocation ([the systems book](https://csapp.cs.cmu.edu/)); Wilson et al.'s [*Dynamic Storage Allocation: A Survey and Critical Review*](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf) for how the designs compare; and Drepper's [*What Every Programmer Should Know About Memory*](https://lwn.net/Articles/250967/), parts [1](https://lwn.net/Articles/250967/)–[2](https://lwn.net/Articles/252852/) for why the cost is in caches, not just correctness.

## What's next

Phase 2 lowers C to machine code: [Machine Language](@/v0.1/phase-2-machine/index.md). You will watch a compiler spill, save, and restore registers, respecting lifetime at each step and never using what it has released. The stack frame from this chapter becomes the centerpiece, examined in depth. Carry one question in: which register holds the answer?

The rule, one last time: **the ledger has one owner per block, and `free` is how you tell it.** Match each block to exactly one owner, and the output you observe matches the standard's promises.
