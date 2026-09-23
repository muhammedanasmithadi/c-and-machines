+++
title = "2C — Bytes"
description = "The add instruction as bytes on two machines, and the rule that orders those bytes."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64 · QEMU 10.2.2 AArch64"
entry = "02"
module_id = "2C"
law = "Every instruction is a number: the bytes are the program."
pretrain = ["byte", "encoding", "little-endian", "fetch", "decode"]
order = 3
forbidden_first_40_lines = ["a second law", "read-the-standard-first"]
opener = "the left column is the program (01 d0, 0x0B000020)"
worked_example = "xxd dump of the AArch64 add encoding"
counterexample = "reading the four bytes back to front (wrong order)"
proof_spec = "Intel SDM (x86 encodings) + ARM ARM (fixed 4-byte width)"
proof_code = "labs/asm binaries + objdump output"
proof_log = "xxd 20 00 00 0b + 2A gate"
practice_retrieve = "objdump bytes from memory + the law"
practice_complete = "str w0/w1 byte pair: name the differing fields"
practice_transfer = "reproduce xxd on your build (compute your offset)"
read_after = "Intel SDM (01 /r); ARM ARM (fixed width); Phase 0 App. A"
appendix = "none"
+++

<div class="epigraph">
<p>Every instruction is a number: the bytes are the program.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

The left column of each listing in [2A](@/v0.1/phase-2-machine/2a-two-dialects/index.md) is the program itself: `01 d0` is the addition on x86-64, two bytes the processor fetches, decodes, and executes. The encoding means: combine `%edx` and `%eax`, and leave the sum in `%eax`. `0x0B000020` is the addition on AArch64: four bytes, and every AArch64 instruction is exactly four wide. (`objdump` prints the encoding bare, as `0b000020`, without the prefix. A leading `0b` reads as binary in C23, so this page writes the `0x`.) Two bytes on x86-64 because this instruction is two bytes long: x86-64 instructions run 1 to 15 bytes, and the left column shows the whole instruction however long it is. The AArch64 encoding means: take `w1` and `w0`, add them, put the sum in `w0`. Assemblers turn text into these bytes; disassemblers turn them back. For these two listings, nothing is lost in either direction, which is why `objdump` can show both side by side with nothing hidden.

Five names, compactly. A **byte** is eight bits, the smallest addressable unit. An **encoding** is the byte form of one instruction: `01 d0` on x86-64, `0x0B000020` on AArch64. **Little-endian** means the least significant byte lives at the lowest address. **Fetch** brings the bytes in. **Decode** reads what they say.

Find the `add` bytes in each listing once more. A C program is text you write, and it is also bytes the machine reads. Both descriptions are complete. When they disagree about what happens next, the bytes win, because the bytes are what runs.

**Every instruction is a number: the bytes are the program.** The text you write, the listing you read, and the bytes the machine fetches are three views of one thing. When two views disagree, trust the bytes.

## The order inside an encoding

Phase 0 read a signature byte by byte. Here a whole encoding shows the other direction: `objdump` prints the bare encoding `0b000020`, but little-endian memory stores those four bytes as `20 00 00 0b`. Dump the encoding at the AArch64 `add` yourself and watch the order flip:

```txt
$ xxd -s 0x744 -l 4 build-aarch64/add
00000744: 2000 000b
```

Least significant byte first: `20`, then `00`, `00`, `0b`. The processor fetches these four bytes and decodes the same `add w0, w1, w0` the listing shows. Reference: aarch64-linux-gnu-gcc 16.2.1, `-O0 -g -Wall -Wextra -std=c11`, Fedora 44 x86-64 host, 2026-09-23. Your build may place the encoding at a different offset; use `objdump -h` to find `.text` and compute your own.

This offset is into the file, not the `0x400744` address `objdump` prints beside the instruction. That address is the encoding's runtime home; the file offset is where it sits on disk. Practice 3 walks between the two, so the difference is a measurement before it is a surprise.

## The wrong order

The same four bytes back to front are `0b 00 00 20`. Ask `objdump` to read those bytes as AArch64, next to the forward order it already decoded:

```txt
$ printf '\x20\x00\x00\x0b' > fwd.bin
$ aarch64-linux-gnu-objdump -b binary -m aarch64 -D fwd.bin
fwd.bin:     file format binary


Disassembly of section .data:

0000000000000000 <.data>:
   0:	0b000020 	add	w0, w1, w0
$ printf '\x0b\x00\x00\x20' > rev.bin
$ aarch64-linux-gnu-objdump -b binary -m aarch64 -D rev.bin
rev.bin:     file format binary


Disassembly of section .data:

0000000000000000 <.data>:
   0:	2000000b 	.inst	0x2000000b ; undefined
```

The forward order decodes to the `add`. The reversed order matches nothing the processor implements, and `objdump` prints it as undefined instead of an instruction. Same four bytes, both orders on the record: the order is load-bearing. Reference: GNU objdump 2.46.1, Fedora 44 x86-64, 2026-09-23.

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
    <p>The <code>xxd</code> stanza above is the machine's answer for the AArch64 encoding, and 2A's gate (<code>VERIFIED ./build/add</code>, <code>add: 42</code> on both ISAs) is the answer for both byte streams: fetched, decoded, summed correctly.</p>
  </div>
</div>

## Practice

1. Without looking back, write the bytes `objdump` prints beside the `add` on each ISA, exactly as printed (bare hex). Then check both against 2A's listings.
2. 2A's AArch64 listing holds two stores: `b9000fe0` beside `str w0, [sp, #12]` and `b9000be1` beside `str w1, [sp, #8]`. Name the two fields that differ between the lines. Then say, in your own words, what the encoding must record beyond the opcode.
3. Reproduce the `xxd` line on your build. Your offset may differ from `0x744`; find `.text` with `aarch64-linux-gnu-objdump -h`, compute the file offset of the `add` encoding from its runtime address, and dump four bytes. Confirm the order flips the same way.
4. Close the page. Write the law in one sentence. Write why the bytes win when the C text and the listing disagree.

Read after you finish, not before: the Intel SDM ([the Intel manuals index](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)) for the byte definitions (look for the `01 /r` ADD encoding); the ARM Architecture Reference Manual for the fixed four-byte width. Phase 0's Appendix A holds the ELF signature these bytes sit inside.

## What's next

Phase 3 puts these instructions on a real processor, with caches and a memory hierarchy between the bytes and the execution. You will measure your program's cache behavior and explain it. The listings above are what the processor fetches; the next chapter watches how fast they arrive. Carry one question in: what stands between the bytes and their execution?

The rule, one last time: **Every instruction is a number: the bytes are the program.** Learn to read the bytes first, and the behavior is on the record.
