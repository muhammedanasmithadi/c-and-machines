+++
title = "1B — Lifetime"
description = "The function returns, the block exits, and the pointer's value becomes indeterminate. The winner program, the rule, and two fixes."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
entry = "01"
module_id = "1B"
law = "When the block exits, the automatic object's lifetime ends and the pointer's value becomes indeterminate."
pretrain = ["object", "address", "pointer", "lifetime", "automatic storage"]
order = 2
+++

<div class="epigraph">
<p>When the block exits, the automatic object's lifetime ends and the pointer's value becomes indeterminate.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Last page, `p` was valid because `x` was still in scope. What if the function that owns `x` has already returned? Predict what this prints. Then compile it twice, at `-O0` and `-O2`. Write your prediction down before you run.

<div class="code-label">winner.c</div>

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

On the reference build (GCC 16, Fedora 44, x86-64) both binaries crash, at both `-O0` and `-O2`. The compiler has already replaced the would-be address with `NULL`.

If you predicted 7, that is the usual first guess: nobody overwrote the slot yet. The C standard does not promise 7. On this GCC it crashes. On this Clang it may print 7 or junk. All of those are legal. The next section is why. One rule, not three compilers.

## Why the address is invalid

You can see why someone would expect `7`. Nothing overwrote that stack slot between the return and the read, so the value should still be sitting there. The standard says otherwise. Here is why.

`winner` returns `&local`. The address bits survive the return. The object does not, and from that moment the standard calls the pointer's value indeterminate. The object it names is gone.

`local` has **automatic storage duration**. Section 6.2.4 of the C standard sets its lifetime: the object exists from entry into the block until exit from the block. When `winner` returns, the block exits and the lifetime ends. The pointer still holds the old address, but no object lives there anymore.

That pointer is **dangling**. It points where its object used to live. The address is unchanged, but the standard guarantees nothing behind it now.

This is a property of the language, and two sentences from **6.2.4p2** state it:

- "If an object is referred to outside of its lifetime, the behavior is undefined."
- "The value of a pointer becomes indeterminate when the object it points to (or just past) reaches the end of its lifetime."

The standard chooses its word carefully: the value becomes *indeterminate*. On the stack, the slot now belongs to whichever function runs next. After a `free`, the block belongs to the allocator again. Either way, that pointer reads bytes no one owns. Open the program above and mark the line after which `local` is gone.

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

**When the block exits, the automatic object's lifetime ends and the pointer's value becomes indeterminate.** That is the whole rule. Everything else on this page is that sentence, working.

## Why two compilers disagree

The four listings in the appendix show the same `winner.c` compiled on two ISAs with two compilers. Read each `winner` and find where the returned value comes from. Clang computes the slot's address and returns it. The stack slot survives into `main`, so the read may still find the `7`. GCC takes the other path. It replaces the address with `0x0` before the program runs:

```txt
; GCC 16, -O0, winner.c — winner(): the address is gone
winner:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $7, -0x10(%rbp)  ; local.points = 7
    mov     $0x0, %eax       ; RAX = 0: &local folded to NULL
    popq    %rbp
    ret
```

GCC does not return the slot. It returns 0. The crash is the read of that 0 in `main`. Both compilers obey the same rule: the value was indeterminate, so each produced a legal one. This disagreement is a transfer item, not the definition. The definition is the lifetime rule above.

## Two correct designs

The two fixes you can apply to `winner` have the same shape: fit the lifetimes together.

The first fix extends the object's lifetime. Give the object static storage duration.

<div class="code-label">winner() — static storage variant</div>

```c
Entry *winner(void) {
  static Entry stored;
  stored.points = 7;
  return &stored;
}
```

The object survives the return. One copy exists for the whole program, and the caller may use the pointer at any time. Put that variant in a file with a `main` that calls it twice, and compare the two addresses:

```txt
$ ./static_twice
a=0x403020 b=0x403020 same=1
```

Same address both times, because one object serves every call. The cost: the function is no longer reentrant. Two callers that each expect their own result now share one object, so the second call overwrites the first. If your program needs distinct results per call, this design breaks. Section 6.2.4 defines what static duration provides. You will stop needing the static trick once you can own heap objects. Do not start there.

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

The object lives until `free`, and ownership moves to the caller. The lab builds on this design. Convert `winner` to this shape yourself in the practice below and prove it under the sanitizer.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The lab file <code>labs/malloc/tests/dangling.c</code> reads through an address whose block has exited (line 13). The opener <code>winner.c</code> above is the same bug with a struct.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>The C standard, quoted above, is the contract. The read happens after the lifetime ends, so the behavior is undefined and the pointer value is indeterminate.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>Under AddressSanitizer, the read of the dead address traps at the exact line. The UndefinedBehaviorSanitizer line and the SEGV record GCC's fold to NULL.</p>
  </div>
</div>

```txt
$ ./build-asan/dangling
tests/dangling.c:13:3: runtime error: load of null pointer of type 'int'
==NNNN==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000000 (pc 0x000000400636 ...)
==NNNN==The signal is caused by a READ memory access.
==NNNN==Hint: address points to the zero page.
    #0 0x000000400636 in main tests/dangling.c:13
SUMMARY: AddressSanitizer: SEGV tests/dangling.c:13 in main
==NNNN==ABORTING
```

The `==NNNN==` masks the process id, which changes each run. Everything else is as the tools wrote it. Reference: GCC 16.2.1 with `-fsanitize=address,undefined`, Fedora 44, x86-64, 2026-09-16. The ledger bugs' transcripts and the other ISA live in [1C](@/v0.1/phase-1-pointers/1c-allocator/index.md); the other compilers' listings are in the appendix below.

A pointer is a promise that an object is still alive. The machine does not store the promise. If you break it, the C standard calls the behavior undefined: crash, garbage, or a lucky correct print.

## Practice

1. Run `winner.c` at `-O0` and `-O2`. Record both outputs.
2. Mark the source line after which `local` is gone.
3. Close the page. Write the law in one sentence. Write why printing 7 is still a failure.
4. Apply the static fix. Call `winner` twice. Report whether the addresses match.
5. Convert `winner` to the heap-storage variant above. Free the block exactly once in `main`. Run it plain and confirm it prints `7` with exit 0, then rebuild with `-fsanitize=address,undefined` and confirm the sanitizer stays silent.
6. (Stretch) Open *one* listing in the appendix below, the compiler you have, and find the instruction that produces the return value.

Read after you finish, not before: C11 **§6.2.4** ([the N1570 draft text](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf)), the two sentences quoted above. Look for the word *indeterminate*.

## Appendix — the four listings

The same `winner.c` on two ISAs with two compilers. Read each `winner` and find where the returned value comes from.

{% raw %}
<div class="tabs" role="tablist">
  <ul class="tab-list">
    <li><button role="tab" data-active="true">clang x86-64</button></li>
    <li><button role="tab">clang AArch64</button></li>
    <li><button role="tab">GCC -O0</button></li>
    <li><button role="tab">GCC -O2</button></li>
  </ul>
  <div class="tab-panel" role="tabpanel">
<pre><code>; clang 22, x86-64, -O0, winner.c — winner(): the address survives
winner:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $7, -4(%rbp)     ; local.points = 7
    leaq    -20(%rbp), %rax  ; RAX = address of local (the whole struct)
    popq    %rbp
    retq                     ; return that address</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; clang 22, AArch64, -O0, winner.c — winner(): the address survives
winner:
    sub     sp, sp, #32      ; carve a frame for local
    add     x0, sp, #12      ; X0 = address of local (the whole struct)
    mov     w8, #7
    str     w8, [sp, #28]    ; local.points = 7
    add     sp, sp, #32      ; frame torn down
    ret                      ; X0 returned</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; GCC 16, -O0, winner.c — winner(): the address is gone
winner:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $7, -0x10(%rbp)  ; local.points = 7
    mov     $0x0, %eax       ; RAX = 0: &local folded to NULL
    popq    %rbp
    ret</code></pre>
  </div>
  <div class="tab-panel" role="tabpanel" hidden>
<pre><code>; GCC 16, -O2, winner.c — winner(): the address is gone
winner:
    xor     %eax, %eax       ; RAX = 0 again
    ret                      ; the whole body collapses</code></pre>
  </div>
</div>
{% endraw %}

The four listings fall into two camps. Clang computes the slot's address and returns it. The stack slot survives into `main`, so the read may still find the `7`. The `-O0` run printed `7`: consistent with a slot nothing had reused yet. The `-O2` run printed junk, consistent with reuse before the read; tracing whose reuse is exactly the kind of question Phase 2 teaches you to answer from disassembly. GCC takes the other path. It replaces the address with `0x0` before the program runs. At `-O0` it still stores `7` to the dead slot, then folds the address anyway. At `-O2` the whole body collapses to `xor %eax,%eax; ret`, and the NULL dereference is the crash in the log. Each listing is the machine's answer on that toolchain. The rule is the same on both architectures.
