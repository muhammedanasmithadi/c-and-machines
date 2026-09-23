+++
title = "Pointers and Lifetime"
description = "Phase 1 explains storage duration, why a returned address can be invalid, and how to prove the fix with spec, code, and log."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
entry = "01"
order = 1
+++

# Phase 1 — Pointers and Lifetime

<div class="epigraph">
<p>An address is only as good as the object it points to.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Here is a short C program. Its file is named `epilogue.c` for the function epilogue (the `popq`/`retq` teardown, not a function by that name) where the lifetime of `local` ends. Predict what it prints, then run it.

<div class="code-label">epilogue.c</div>

```c
/* a pointer that outlives its object */
#include <stdio.h>

typedef struct {
  char name[16];
  int points;
} Entry;

Entry *winner(void) {
  Entry local;
  local.points = 7;
  return &local;
}

int main(void) {
  Entry *w = winner();
  printf("%d\n", w->points);
  return 0;
}
```

Compile it twice, then compare the result with your prediction. On the reference build (GCC 16, Fedora 44, x86-64) both binaries crash, at both `-O0` and `-O2`. The compiler has already replaced the would-be address with `NULL`. Clang 22, given the same source, keeps the literal address of the dead stack slot, and the program prints whatever the next occupant of that slot left behind. One source, two toolchains: a crash on one, a printed value on the other.

Either outcome is the compiler's legal answer, and both repay a run on your machine. The lesson starts at the cause. Why does a pointer to a local variable stop being good the moment the function returns?

<aside class="sidenote">The standard makes no promise about this program. That is what undefined behavior means: each compiler may do anything at all, including replacing the address with `NULL`. The dangling case in this lesson shows exactly that.</aside>

## Why the address is invalid

You can see why someone would expect `7`. Nothing overwrote that stack slot between the return and the read, so the value should still be sitting there. The standard says otherwise. Here is why.

`winner` returns `&local`. The address bits survive the return. The object does not, and from that moment the standard calls the pointer's value indeterminate. The object it names is gone.

`local` has **automatic storage duration**. Section 6.2.4 of the C standard sets its lifetime: the object exists from entry into the block until exit from the block. When `winner` returns, the block exits and the lifetime ends. The pointer still holds the old address, but no object lives there anymore.

That pointer is **dangling**. It points where its object used to live. The address is unchanged, but the standard guarantees nothing behind it now.

This is a property of the language, and two sentences from **6.2.4p2** state it:

- "If an object is referred to outside of its lifetime, the behavior is undefined."
- "The value of a pointer becomes indeterminate when the object it points to (or just past) reaches the end of its lifetime."

The standard chooses its word carefully: the value becomes *indeterminate*. On the stack, the slot now belongs to whichever function runs next. After a `free`, the block belongs to the allocator again. Either way, that pointer reads bytes no one owns. Open the program above and mark the line after which `local` is gone.

## The three ways lifetime goes wrong

Every lifetime bug in this book is one of three failures of bookkeeping:

1. **Use after free.** You read or write through a pointer after the object's lifetime has ended. The opening program does this: `winner` returns `&local`, and `w->points` reads past the block's exit. Match each of the three to its row in the table below.
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

## Lifetime, not syntax

The C standard divides storage into four durations. Each row says when the object exists and when the storage stops being yours. These are the machine's terms. The code must fit them.

| Duration | Object exists | What ends it |
|---|---|---|
| Automatic | until the block exits | block exit |
| Static | whole program | program exit |
| Thread | thread's lifetime | thread exit |
| Allocated | until `free` | your `free` |

<aside class="sidenote"><a href="http://booksite.elsevier.com/9780128017333/">Patterson and Hennessy</a> (Chapter 2, "Instructions: Language of the Computer", [the book](http://booksite.elsevier.com/9780128017333/)) place each of these rows in a distinct region of virtual memory in a typical Linux process. The four rows name the stack, the data segment, the TLS block, and the heap: four regions the OS places at distinct addresses.</aside>

The mistake in `winner` fits one row of that table: it returned a pointer to an automatic object, and the caller used it after the block exited. Point to that row before reading on.

## Two correct designs

The two fixes you can apply to `winner` have the same shape, shown in turn.

The first fix extends the object's lifetime. Give the object static storage duration.

<div class="code-label">winner() — static storage variant</div>

```c
Entry *winner(void) {
  static Entry stored;
  stored.points = 7;
  return &stored;
}
```

The object survives the return. One copy exists for the whole program, and the caller may use the pointer at any time. The cost: the function is no longer reentrant. Two callers that each expect their own result now share one object, so the second call overwrites the first. If your program needs distinct results per call, this design breaks. Section 6.2.4 defines what static duration provides.

The second fix hands the caller responsibility for the object's lifetime. Allocate the object on the heap, and let the caller free it.

<div class="code-label">winner() — heap-storage variant</div>

```c
#include <stdlib.h>

Entry *winner(void) {
  Entry *p = malloc(sizeof *p);
  if (p) p->points = 7;
  return p;               /* caller must free() this exactly once */
}
```

The object lives until `free`, and ownership moves to the caller. The lab builds on this design.

The rule for this section: **a pointer is valid only while the object it names is alive.** Make the pointer's lifetime fit the object's, or the object's fit the pointer's.

Compile both variants. Call each one twice in a row and print both results. The static version hands back the same address both times. The heap version hands back two addresses, and each needs exactly one `free`. Then decide: which contract can your caller keep?

## The allocator's ledger

`malloc` manages the heap with a ledger. The ledger records every block: its address, its size, whether it is free. For the full mechanism, read [CS:APP §9.9](https://csapp.cs.cmu.edu/) and the [Wilson survey](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf). Both describe real allocators as this bookkeeping plus a search policy.

Three facts about the ledger explain the three bugs:

- `free(p)` removes your block from the ledger. From that moment, the block belongs to the allocator, not to you. Using `p` after `free` reads a block whose entry no longer has your name.
- A double free happens when two parts of a program each believe they own the block. The ledger is not designed for two owners.
- The allocator reclaims blocks only when told. A block you never free stays in the ledger, marked occupied, even if nothing references it. Read the three facts as three ledger rules, then walk them in the stepper below.

The proof below runs the four programs against the tools and shows what the ledger records for each.

## What the machine does with it

A pointer is an address, and an address is a number. The difference between the two compilers shows up in the instructions that produce that number. The four tabs show the same `epilogue.c` compiled on two ISAs with two compilers. Read each `winner` and find where the returned value comes from.

{% raw %}
<div class="tabs" role="tablist">
  <ul class="tab-list">
    <li><button role="tab" data-active="true">clang x86-64</button></li>
    <li><button role="tab">clang AArch64</button></li>
    <li><button role="tab">GCC -O0</button></li>
    <li><button role="tab">GCC -O2</button></li>
  </ul>
  <div class="tab-panel" role="tabpanel">
<pre><code>; clang 22, x86-64, -O0, epilogue.c — winner(): the address survives
winner:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $7, -4(%rbp)     ; local.points = 7
    leaq    -20(%rbp), %rax  ; RAX = address of local (the whole struct)
    popq    %rbp
    retq                     ; return that address</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; clang 22, AArch64, -O0, epilogue.c — winner(): the address survives
winner:
    sub     sp, sp, #32      ; carve a frame for local
    add     x0, sp, #12      ; X0 = address of local (the whole struct)
    mov     w8, #7
    str     w8, [sp, #28]    ; local.points = 7
    add     sp, sp, #32      ; frame torn down
    ret                      ; X0 returned</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; GCC 16, -O0, epilogue.c — winner(): the address is gone
winner:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $7, -0x10(%rbp)  ; local.points = 7
    mov     $0x0, %eax       ; RAX = 0: &local folded to NULL
    popq    %rbp
    ret</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; GCC 16, -O2, epilogue.c — winner(): the address is gone
winner:
    xor     %eax, %eax       ; RAX = 0 again
    ret                      ; the whole body collapses</code></pre>
  </div>
</div>
{% endraw %}

The four listings fall into two camps. Clang computes the slot's address and returns it. The stack slot survives into `main`, so the read may still find the `7`. The `-O0` run printed `7`: consistent with a slot nothing had reused yet. The `-O2` run printed junk, consistent with reuse before the read; tracing whose reuse is exactly the kind of question Phase 2 teaches you to answer from disassembly. GCC takes the other path. It replaces the address with `0x0` before the program runs. At `-O0` it still stores `7` to the dead slot, then folds the address anyway. At `-O2` the whole body collapses to `xor %eax,%eax; ret`, and the NULL dereference is the crash in the log. Each listing is the machine's answer on that toolchain. The rule is the same on both architectures.

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
    <p>The C standard, quoted above, is the contract. `dangling.c` reads through `&x` after the block exits (line 13), `doublefree.c` returns one block twice (lines 11–12), `leak.c` never returns its 40 bytes. The tools then show the proof.</p>
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

$ ./build-asan/dangling
tests/dangling.c:13:3: runtime error: load of null pointer of type 'int'
==NNNN==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000000 (pc 0x000000400636 ...)
==NNNN==The signal is caused by a READ memory access.
==NNNN==Hint: address points to the zero page.
    #0 0x000000400636 in main tests/dangling.c:13
SUMMARY: AddressSanitizer: SEGV tests/dangling.c:13 in main
==NNNN==ABORTING

$ ./build-asan/fixed
fixed: 42

$ make -C labs/malloc check
VERIFIED ./build-asan/leak
VERIFIED ./build-asan/doublefree
VERIFIED ./build-asan/dangling
VERIFIED ./build-asan/fixed
```

Every line here is the machine's own. The `==NNNN==` masks the process id, which changes each run; the heap address `0x7ac...` changes with the allocator's state. Everything else is as the tools wrote it. The gate runs each binary and prints one VERIFIED line per program, shown last. Run each binary by hand for the full stack, the register dump, and the exact heap addresses, unshortened. Reference: GCC 16.2.1 with `-fsanitize=address,undefined`, Fedora 44, x86-64, 2026-09-16.

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

The double-free is caught at the second `free`, exactly where the source breaks the rule. The dangling case deserves a close look. `return &local` hands out an address whose lifetime ends at the block's exit: forming the address is legal, but the undefined behavior happens when the caller uses it afterward. GCC 16 folds the would-be address into `NULL`. The UndefinedBehaviorSanitizer line ("load of null pointer") and the SEGV on address 0x000000000000 record that fold. The crash is deterministic on this build. Its cause is line 13 of `dangling.c`, the line that reads through the dead pointer.

## Practice

`labs/malloc/` contains `epilogue.c` (the opening program), `leak.c`, `doublefree.c`, `dangling.c`, and `fixed.c`. Your work:

1. Build with `gcc -O0 -g -Wall -Wextra -std=c11` and run each binary. Note which fail and which pass *on the surface*.
2. Run `make -C labs/malloc check` and see each verdict against the ASan build.
3. Cross-build the same sources for AArch64 and run them under QEMU. Follow `labs/malloc/notes/arm.md`. The lesson must hold on the other ISA too.
4. Fix the three broken files so all three pass under ASan and Valgrind. For `dangling.c` the fix is the static-duration design; for `doublefree.c`, a `free` per `malloc`, one owner; for `leak.c`, the missing `free`.

Read in this order: K&R 2e ([the C book](https://9p.io/cm/cs/cbook/)), **Ch 5–6** (pointers and structures) and Appendix A (storage classes); CS:APP 3e **§9.9** for dynamic allocation ([the systems book](https://csapp.cs.cmu.edu/)); Wilson et al.'s [*Dynamic Storage Allocation: A Survey and Critical Review*](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf) ([where the designs are compared](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf)); and Drepper's [*What Every Programmer Should Know About Memory*](https://lwn.net/Articles/250967/), parts [1](https://lwn.net/Articles/250967/)–[2](https://lwn.net/Articles/252852/) (why the cost is in caches, not just correctness).

## What's next

Phase 2 lowers C to machine code. You will watch a compiler spill, save, and restore registers, respecting lifetime at each step and never using what it has released. The stack frame from this chapter becomes the centerpiece, examined in depth. Carry one question in: which register holds the answer?

Phase 3 puts that machine code on a real processor, with caches and a memory hierarchy. You will measure your program's cache behavior and explain it.

Phase 4 brings the same bookkeeping to the whole system: virtual memory, page tables, and the kernel's record of which pages are resident. Whether that pointer can actually be read then depends on page residency too, not just your `malloc` call. Lifetime at the small scale follows the same rule as lifetime at the large scale.

The rule, one last time: **an address is only as good as the object it points to.** Match each pointer's lifetime to its object, and the output you observe matches the standard's promises.

---

*Sources: C11 refs via N1570 draft, 6.2.4, 7.22.3; [K&R 2e](https://9p.io/cm/cs/cbook/) Ch 5–6, App A; [CS:APP 3e](https://csapp.cs.cmu.edu/) §9.9; [Wilson et al. (1995)](https://csapp.cs.cmu.edu/3e/docs/dsa.pdf); [Drepper (2007)](https://lwn.net/Articles/250967/). Prose follows WRITING.md: concrete first, mechanism before law; the machine judges.*