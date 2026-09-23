+++
title = "1A — A pointer is an address of a live object"
description = "A safe pointer program that obeys the lifetime rule, with the three names every later module reuses."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
entry = "01"
module_id = "1A"
law = "A pointer is valid only while the object it names is alive."
pretrain = ["object", "address", "pointer", "&", "*"]
order = 1
+++

<div class="epigraph">
<p>A pointer is valid only while the object it names is alive.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

A pointer holds an address. The address is only usable while something real lives there. Three terms, then a program.

| Term | Meaning in this chapter |
|---|---|
| object | a named piece of storage (`x`, `local`) |
| address | the number that locates that storage (`&x`) |
| pointer | a variable that stores an address (`int *p`) |
| `&` | address-of: `&x` is where `x` lives |
| `*` | dereference: `*p` is the object `p` names |

Run this. Predict the print first.

<div class="code-label">live.c</div>

```c
#include <stdio.h>

int main(void) {
  int x = 7;
  int *p = &x;
  printf("%d\n", *p);   /* 7: p names a live object */
  return 0;
}
```

```txt
$ gcc -O0 -g -Wall -Wextra -std=c11 live.c -o live
$ ./live
7
```

It prints 7 because `x` is still alive when `*p` reads it. The pointer `p` holds the address of `x`, and `x` exists for the whole block, so the read finds the object. Nothing here is special: one object, one address, one read while the owner still stands.

**A pointer is valid only while the object it names is alive.** The sentence has two halves and both matter. The first half names what the pointer holds. The second half names the condition that makes the hold good.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The program above. One block, one object, no function to return from.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>C11 §6.2.4 gives every object a lifetime. An object with automatic storage exists until its block exits. The block here never exits before the read, so the read is defined.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>The machine's answer is the single line <code>7</code> above. Reference: GCC 16.2.1, <code>-O0 -g -Wall -Wextra -std=c11</code>, Fedora 44, x86-64, 2026-09-23.</p>
  </div>
</div>

## Practice

1. Close the page. Write the law in one sentence. Then reopen and check.
2. Change `7` to `41`. Predict the print before you rebuild, then run and confirm.
3. Add a second pointer after `int *p = &x;`: `int *q = p;` Print `*q`. Predict first. Why does it print the same value?

Read after you finish, not before: K&R 2e ([the C book](https://9p.io/cm/cs/cbook/)), **Ch 5**, for what `&` and `*` promise (address-of and dereference).

Next page a function returns the address of its own local, and that stops being true: [1B — Lifetime](@/v0.1/phase-1-pointers/1b-lifetime/index.md).
