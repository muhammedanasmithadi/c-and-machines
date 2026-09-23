+++
title = "2C — Bytes"
description = "The left column is the program. One addition in two bytes and four, and the order those bytes live in."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64 · QEMU 10.2.2 AArch64"
entry = "02"
module_id = "2C"
law = "Every instruction is a number: the bytes are the program."
pretrain = ["byte", "word", "little-endian", "fetch", "decode"]
order = 3
+++

<div class="epigraph">
<p>Every instruction is a number: the bytes are the program.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

The left column of each listing in [2A](@/v0.1/phase-2-machine/2a-two-dialects/index.md) is the program itself: `01 d0` is the addition on x86-64, two bytes the processor fetches, decodes, and executes. `0b000020` is the addition on AArch64: four bytes, and every AArch64 instruction is exactly four wide. Assemblers turn text into these bytes; disassemblers turn them back. For these two listings, nothing is lost in either direction, which is why `objdump` can show both side by side with nothing hidden.

Five names, compactly. A **byte** is eight bits, the smallest addressable unit. A **word** is the unit `objdump` prints: two bytes on x86-64 here, four on AArch64. **Little-endian** means the least significant byte lives at the lowest address. **Fetch** brings the bytes in. **Decode** reads what they say.

Find the `add` bytes in each listing once more. A C program is text you write, and it is also bytes the machine reads. Both descriptions are complete. When they disagree about what happens next, the bytes win, because the bytes are what runs.

## The order inside a word

Phase 0 read a signature byte by byte. Here a whole word shows the other direction: `objdump` prints the word `0b000020`, but little-endian memory stores those four bytes as `20 00 00 0b`. Dump the word at the AArch64 `add` yourself and watch the order flip:

```txt
$ xxd -s 0x744 -l 4 build-aarch64/add
00000744: 2000 000b
```

Least significant byte first: `20`, then `00`, `00`, `0b`. The processor fetches these four bytes and decodes the same `add w0, w1, w0` the listing shows. Reference: aarch64-linux-gnu-gcc 16.2.1, `-O0 -g -Wall -Wextra -std=c11`, Fedora 44 x86-64 host, 2026-09-23. Your build may place the word at a different offset; use `objdump -h` to find `.text` and compute your own.

**Every instruction is a number: the bytes are the program.** The text you write, the listing you read, and the bytes the machine fetches are three views of one thing. When two views disagree, trust the bytes.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The binaries are <code>labs/asm/build/add</code> and <code>build-aarch64/add</code>, with <code>objdump -d</code> output kept beside each. The left columns above come from those files.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>The Intel SDM defines the x86 byte encodings; the ARM Architecture Reference Manual fixes every AArch64 instruction at four bytes. The listings obey both.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>The <code>xxd</code> stanza above is the machine's answer for the AArch64 word, and 2A's gate (<code>VERIFIED ./build/add</code>, <code>add: 42</code> on both ISAs) is the answer for both byte streams: fetched, decoded, summed correctly.</p>
  </div>
</div>

## Practice

1. Find the `add` bytes in each listing in 2A once more, without scrolling back to this page's quotes. Write both byte strings from memory, then check.
2. Reproduce the `xxd` line on your build. Your offset may differ from `0x744`; find `.text` with `aarch64-linux-gnu-objdump -h`, compute the file offset of the `add` word, and dump four bytes. Confirm the order flips the same way.
3. Close the page. Write the law in one sentence. Write why the bytes win when the C text and the listing disagree.

Read after you finish, not before: the Intel SDM ([the Intel manuals index](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)) for the byte definitions (look for the `01 /r` ADD encoding); the ARM Architecture Reference Manual for the fixed four-byte width. Phase 0's Appendix A holds the ELF signature these bytes sit inside.

## What's next

Phase 3 puts these instructions on a real processor, with caches and a memory hierarchy between the bytes and the execution. You will measure your program's cache behavior and explain it. The listings above are what the processor fetches; the next chapter watches how fast they arrive. Carry one question in: what stands between the bytes and their execution?

The rule, one last time: **every instruction is a number: the bytes are the program.** Learn to read the bytes first, and the behavior is on the record.
