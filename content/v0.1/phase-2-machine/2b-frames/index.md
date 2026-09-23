+++
title = "2B — Frames"
description = "The setup line and the teardown line, and where Phase 1's local ended between them."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64 · QEMU 10.2.2 AArch64"
entry = "02"
module_id = "2B"
law = "The object lives between the setup line and the teardown line."
pretrain = ["frame", "stack pointer", "base pointer", "setup", "teardown"]
order = 2
forbidden_first_40_lines = ["BTI", "a second law", "read-the-standard-first"]
opener = "2A listings build and tear down frames (twist on dialects)"
worked_example = "setup/teardown excerpts per ISA"
counterexample = "-O2 collapsing the frame away"
proof_spec = "C11 §6.2.4 via 1B (teardown lines are the block exit)"
proof_code = "2A listings at -O0 + winner.c"
proof_log = "2A gate (frames built, held a and b, tore down around 42)"
practice_retrieve = "write the law; why post-teardown addresses fail"
practice_complete = "cover each listing, point at its teardown line"
practice_transfer = "count spills at -O0, predict -O2"
read_after = "AMD64 ABI + AAPCS64 (register preservation)"
appendix = "none"
+++

<div class="epigraph">
<p>The object lives between the setup line and the teardown line.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Both listings in [2A](@/v0.1/phase-2-machine/2a-two-dialects/index.md) build a stack frame on entry and tear it down on exit at `-O0`: x86-64 pushes the old base pointer and anchors `%rbp`; AArch64 subtracts 16 from the stack pointer. The stores and loads between those two lines are the function's short-term memory: `a` and `b` live at frame offsets for the few instructions that need them.

Five names, then the lines. The **frame** is the function's reserved stretch of stack. The **stack pointer** names its moving end. The **base pointer** (`%rbp` on x86-64) anchors it for the function's duration. **Setup** reserves the frame. **Teardown** releases it.

Here are the two lines per side, copied from 2A's listings. Setup first:

```txt
push   %rbp              ; x86-64: save the old anchor
mov    %rsp,%rbp         ; x86-64: anchor the new frame
sub	sp, sp, #0x10     ; AArch64: carve 16 bytes
```

Then the teardown, the last lines before each return:

```txt
pop    %rbp              ; x86-64: release the frame
add	sp, sp, #0x10     ; AArch64: give the 16 bytes back
```

**The object lives between the setup line and the teardown line.** Not one instruction longer: the stores and loads above sit between those lines because the frame exists there. Past the teardown, the reservation is gone, so any address into it names released storage.

## Where Phase 1's `local` ended

This is the kind of frame Phase 1 saw torn down. `winner` returned an address into exactly this structure after the teardown lines ran. Find the teardown in each listing in 2A: `pop %rbp` on one side, `add sp, sp, #0x10` on the other. Find them, and the dangling pointer stops being abstract. Per the law above, `local` lived between those two lines. (`-O2` may skip the frame entirely, as the collapsed `winner` in [1B's appendix](@/v0.1/phase-1-pointers/1b-lifetime/index.md) shows. One more reason to read the listing.)

Module 1B's law said the pointer's value becomes indeterminate when the block exits. These two teardown lines are where that exit happens on the machine. The standard names the rule; the listing shows the lines.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The listings are <a href="@/v0.1/phase-2-machine/2a-two-dialects/index.md">2A's two listings</a>, built by <code>labs/asm/</code> at <code>-O0</code>. The excerpts above are those same instructions, address and byte columns trimmed.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>Module 1B quoted it: C11 §6.2.4 ends an automatic object's lifetime at block exit. The teardown lines are the machine's record of that exit.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>No new binary runs here. The evidence is 2A's gate (<code>VERIFIED ./build/add</code>, <code>add: 42</code> on both ISAs): the frames above built, held <code>a</code> and <code>b</code>, and tore down around a correct sum.</p>
  </div>
</div>

## Practice

1. Open both listings in 2A. Cover each one and point at its teardown line before you look. Then check.
2. Close the page. Write the law in one sentence. Write why an address into the frame is unusable after the teardown.
3. Open both `add.s` files in `labs/asm/` and find where each function spills its arguments. Count the stores. Both spill twice at `-O0`; consider what `-O2` might skip, then compile with `-O2` and read the answer.

Read after you finish, not before: the two procedure-call standards linked in 2A, for how calls preserve registers across the frame (System V AMD64 ABI on the x86 side, AAPCS64 on the ARM side).

Next: the left column of those listings is itself the program. [2C — Bytes](@/v0.1/phase-2-machine/2c-bytes/index.md) reads it.
