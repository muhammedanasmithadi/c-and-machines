+++
title = "Machine Language"
description = "Phase 2 reads one C function in two dialects, x86-64 and AArch64, down to the bytes."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64 · QEMU 10.2.2 AArch64"
entry = "02"
+++

<div class="epigraph">
<p>A C program means whatever its instructions do.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Here is a short C program. Predict what it prints, then predict whether the two machines below spell the sum the same way.

<div class="code-label">add.c</div>

```c
#include <stdio.h>

int add(int a, int b) {
  return a + b;
}

int main(void) {
  printf("add: %d\n", add(40, 2));
  return 0;
}
```

Build it twice and run it twice, once per instruction set:

```txt
$ ./build/add
add: 42
$ qemu-aarch64 -L /usr/aarch64-redhat-linux/sys-root/fc44 build-aarch64/add
add: 42
```

The source is shared; the output matches on both machines. The second run emulates an AArch64 processor in software; QEMU translates each ARM instruction as it goes, and the output is identical. Your prediction about the spelling was the interesting one. Open both listings and compare.

## The x86-64 dialect

`objdump -d` prints the machine bytes beside the instructions they encode. The whole of `add` on x86-64:

<div class="code-label">add — x86-64 machine code</div>

```txt
0000000000400466 <add>:
  400466:	55                   	push   %rbp
  400467:	48 89 e5             	mov    %rsp,%rbp
  40046a:	89 7d fc             	mov    %edi,-0x4(%rbp)
  40046d:	89 75 f8             	mov    %esi,-0x8(%rbp)
  400470:	8b 55 fc             	mov    -0x4(%rbp),%edx
  400473:	8b 45 f8             	mov    -0x8(%rbp),%eax
  400476:	01 d0                	add    %edx,%eax
  400478:	5d                   	pop    %rbp
  400479:	c3                   	ret
```

Cover the listing and predict: which register carries `a` into the `add`? Read on to check. The caller placed the arguments where the System V contract says: first in `%edi`, second in `%esi`. The function spills both to its frame, reloads them into `%edx` and `%eax`, and `add`, bytes `01 d0`, writes the sum over `%eax`. Whatever sits in `%eax` at `ret` is the return value. So `a` travels `%edi`, to the stack, to `%edx`, and the answer leaves in `%eax`. The addresses start at `0x400466`: this toolchain links non-PIE by default. On a PIE-default toolchain the same bytes land elsewhere; the reading does not change.

## The AArch64 dialect

The same function, compiled for ARM's 64-bit instruction set:

<div class="code-label">add — AArch64 machine code</div>

```txt
000000000040072c <add>:
  40072c:	d503245f 	bti	c
  400730:	d10043ff 	sub	sp, sp, #0x10
  400734:	b9000fe0 	str	w0, [sp, #12]
  400738:	b9000be1 	str	w1, [sp, #8]
  40073c:	b9400fe1 	ldr	w1, [sp, #12]
  400740:	b9400be0 	ldr	w0, [sp, #8]
  400744:	0b000020 	add	w0, w1, w0
  400748:	910043ff 	add	sp, sp, #0x10
  40074c:	d65f03c0 	ret
```

Cover the listing and predict where the sum lands before reading on. Same shape, different syllables. The first line, `bti c`, marks a valid indirect-branch target; it guards, it does not compute. The frame setup starts on the next line. The caller placed the arguments in `w0` and `w1`, the 32-bit halves of the `x0` and `x1` registers, per AAPCS64. The function spills both to its frame, reloads them, and `add w0, w1, w0`, bytes `0b000020`, writes the sum over `w0`. The answer leaves in the same register the first argument arrived in.

## Same sum, two dialects

Pick any row and find it in both listings above:

| Job | x86-64 | AArch64 |
|---|---|---|
| First argument arrives in | `%edi` | `w0` |
| Second argument arrives in | `%esi` | `w1` |
| Spill to the frame | `mov` to `(%rbp)` | `str` to `[sp]` |
| Reload for the sum | `mov` to `%edx`, `%eax` | `ldr` to `w1`, `w0` |
| The sum itself | `add %edx,%eax` | `add w0, w1, w0` |
| Answer leaves in | `%eax` | `w0` |
| Return to caller | `ret` | `ret` |

Both columns are the program. Each is what the compiler emitted for its machine, and each runs on its machine. The C source is the shared text; the listings are its two executions. Portability means the behavior survives the change of dialect, and here you watch it survive: `add: 42` on both.

## Frames, built and torn down

Both listings build a stack frame on entry and tear it down on exit. x86-64 pushes the old base pointer and anchors `%rbp`; AArch64 subtracts 16 from the stack pointer. The stores and loads between those two lines are the function's short-term memory: `a` and `b` live at frame offsets for the few instructions that need them.

This is the frame Phase 1 saw torn down. `winner` returned an address into exactly this structure after the teardown lines ran. Find the teardown in each listing above: `pop %rbp` on one side, `add sp, sp, #0x10` on the other. Find them, and the dangling pointer stops being abstract. The object lived between the setup line and the teardown line, and not one instruction longer.

## Bytes are instructions

The left column of each listing is the program itself: `01 d0` is the addition on x86-64, two bytes the processor fetches, decodes, and executes. `0b000020` is the addition on AArch64: four bytes, and every AArch64 instruction is exactly four wide. Assemblers turn text into these bytes; disassemblers turn them back. Neither direction loses information here, which is why `objdump` can show both side by side with nothing hidden.

Find the `add` bytes in each listing once more. A C program is text you write, and it is also bytes the machine reads. Both descriptions are complete. When they disagree about what happens next, the bytes win, because the bytes are what runs.

**A C program means whatever its instructions do.** Read the listing before you predict the behavior, and the behavior stops surprising you.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The lab for this lesson, <code>labs/asm/</code>, builds the same program for both instruction sets, keeps both machine-code listings, and runs each binary: native on x86-64, emulated on AArch64. The cross leg names its sysroot and loader path explicitly; it also carries one documented empty archive that satisfies the driver's stub flag.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>The register contracts are written down. The System V AMD64 ABI names the argument registers and the return register; AAPCS64 does the same for ARM. The listings above obey both documents line by line.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>This is the machine's answer, on both machines. The lab gate checks the native binary, the emulated run, and both listings. Run <code>make -C labs/asm check</code> and match each line of output to its block.</p>
  </div>
</div>

```txt
VERIFIED ./build/add
add: 42
```

The first line is the gate's verdict on x86-64. The second is QEMU's stdout from the AArch64 binary, matched byte for byte. Reference: GCC 16.2.1 and aarch64-linux-gnu-gcc 16.2.1, `-O0 -g -Wall -Wextra -std=c11`, Fedora 44 x86-64 host, qemu-aarch64 10.2.2, 2026-09-22.

## Practice

`labs/asm/` holds `tests/add.c` and the stage Makefile. Your work:

1. Run `make -C labs/asm check` and confirm every line verifies, including the emulated run.
2. Change `+` to `-`, predict the new output, and name the instruction line that must change in each listing before you rebuild. Then rebuild and check both predictions.
3. Run the AArch64 binary without QEMU: `./build-aarch64/add`. Running it prints `cannot execute binary file: Exec format error` and exits 126: the kernel loads only its own machine's format, so the message marks instruction sets as real boundaries.
4. Open both `add.s` files and find where each function spills its arguments. Count the stores. Both spill twice at `-O0`; consider what `-O2` might skip, then compile with `-O2` and read the answer.
5. Write `mul` beside `add`: same shape, `return a * b`, printed from `main`. Predict its two listing lines (the sum lines with the operator swapped), then verify against both outputs.

Read in this order: the System V AMD64 ABI ([the x86-64 psABI project](https://gitlab.com/x86-psABIs/x86-64-ABI)) for the register contract; AAPCS64 ([the procedure-call standard itself](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)) for ARM's; and the Intel SDM ([the x86 manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)) for the byte definitions.

## What's next

Phase 3 puts these instructions on a real processor, with caches and a memory hierarchy between the bytes and the execution. You will measure your program's cache behavior and explain it. The listings above are what the processor fetches; the next chapter watches how fast they arrive. Carry one question in: what stands between the bytes and their execution?

The rule, one last time: **a C program means whatever its instructions do.** Learn to read the listing first, and the behavior is on the record.

---

*Sources: [System V AMD64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI); [AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst); [Intel SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html). Prose follows the classic style with a teaching voice (Thomas & Turner, *Clear and Simple as the Truth*): concrete first, mechanism before law; the machine judges.*
