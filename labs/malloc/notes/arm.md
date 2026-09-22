# AArch64 notes for the malloc lab

The lesson's three lifetime failures are architecture-neutral. Lifetime is language law; registers only carry it out. This lab shows that by running the same sources under an
AArch64 Linux.

## Cross toolchain (Fedora)

```sh
sudo dnf install gcc-aarch64-linux-gnu qemu-user qemu-user-static gdb-multiarch sysroot-aarch64-fc44-glibc
```

## Build and run the suite on AArch64 via QEMU

```sh
make clean
make CC=aarch64-linux-gnu-gcc all
```

Run each binary with QEMU user-mode, pointing at the cross sysroot:

```sh
qemu-aarch64 -L /usr/aarch64-redhat-linux/sys-root/fc44 ./build/leak
qemu-aarch64 -L /usr/aarch64-redhat-linux/sys-root/fc44 ./build/doublefree
qemu-aarch64 -L /usr/aarch64-redhat-linux/sys-root/fc44 ./build/dangling
qemu-aarch64 -L /usr/aarch64-redhat-linux/sys-root/fc44 ./build/fixed
```

`-static` also works if a cross sysroot is not installed:

```sh
make clean
make CFLAGS="-O0 -g -Wall -Wextra -std=c11 -static" CC=aarch64-linux-gnu-gcc all
qemu-aarch64 ./build/fixed
```

## What differs on AArch64

1. **AAPCS64 calling convention.** Arguments in x0..x7, return in x0.
   `malloc` here reaches the dynamic linker through the PLT.
2. **The register map.** Where the x86-64 chapter spills `local` at `[rbp-4]`,
   AArch64 spills at `[sp-#4]` and returns in `x0`. The fault is identical:
   a pointer into a dead frame.
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