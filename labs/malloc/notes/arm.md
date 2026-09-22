# AArch64 notes for the malloc lab

The lesson's three lifetime failures are architecture-neutral. Lifetime is language law; registers only carry it out. This lab shows that by running the same sources under an
AArch64 Linux.

## Cross toolchain (Fedora)

```sh
sudo dnf install gcc-aarch64-linux-gnu qemu-user qemu-user-static gdb-multiarch sysroot-aarch64-fc44-glibc
```

## Build and run the suite on AArch64 via QEMU

The cross driver needs three extras beyond the native flags: the populated
sysroot, the sysroot's loader path, and the empty-archive stub shared with
`labs/asm` (see its Makefile: the distro does not ship `-latomic_asneeded`
for aarch64, and the archive contributes nothing). Build each test by hand:

```sh
SYSROOT=/usr/aarch64-redhat-linux/sys-root/fc44
FLAGS="-O0 -g -Wall -Wextra -std=c11 --sysroot=$SYSROOT -L../shared/lib -Wl,--dynamic-linker=/usr/lib/ld-linux-aarch64.so.1"
mkdir -p build-aarch64
aarch64-linux-gnu-gcc $FLAGS tests/leak.c -o build-aarch64/leak
aarch64-linux-gnu-gcc $FLAGS tests/doublefree.c -o build-aarch64/doublefree
aarch64-linux-gnu-gcc $FLAGS tests/dangling.c -o build-aarch64/dangling
aarch64-linux-gnu-gcc $FLAGS tests/fixed.c -o build-aarch64/fixed
aarch64-linux-gnu-gcc $FLAGS tests/epilogue.c -o build-aarch64/epilogue
```

Run each binary with QEMU user-mode, pointing at the cross sysroot:

```sh
qemu-aarch64 -L $SYSROOT build-aarch64/leak
qemu-aarch64 -L $SYSROOT build-aarch64/doublefree
qemu-aarch64 -L $SYSROOT build-aarch64/dangling
qemu-aarch64 -L $SYSROOT build-aarch64/fixed
qemu-aarch64 -L $SYSROOT build-aarch64/epilogue
```

Expect what the native chapter teaches: `leak` prints `leak: phantom` and exits 0 (the leak is silent without a checker), `doublefree` aborts, `dangling` and `epilogue` segfault, `fixed` prints `fixed: 42`. Same sources, same lifetime law, second ISA.

## What differs on AArch64

1. **AAPCS64 calling convention.** Arguments in x0..x7, return in x0.
   `malloc` here reaches the dynamic linker through the PLT.
2. **The register map.** The x86-64 listings spill `local` below the base pointer (`-4(%rbp)` in Clang's epilogue, `-16(%rbp)` in GCC's). AArch64 spills below the stack pointer (`[sp, #28]` in Clang's, `[sp, 24]` in GCC's) and returns in `x0`. The fault is identical: a pointer into a dead frame.
3. **Memory ordering is weaker than x86 TSO.** The same C code compiles to the same
   allocation calls, but the machine's memory model differs. Phase 5 returns to
   this when locks meet fences (DMB/DSB, LDAR/STLR).
4. **Endianness default is little**, same as x86-64. All pointers on these two targets are 64-bit,
   so `malloc` block sizes and header layout in the survey (Wilson et al.) still
   match the two ISAs.

## Gate for the ARM leg of the lab

`build/fixed` must run under `qemu-aarch64` and print `fixed: 42`.
The three failure binaries must fail under valgrind/ASan on x86-64 from the
same sources. Matching verdicts on both ISAs show the law sits in the
language, not in one instruction set.