+++
title = "Bits and the Toolchain"
description = "Phase 0 follows one C program through four stages into bytes, and shows the shell keeping score."

[extra]
ref_build = "GCC 16.2.1 · Fedora 44 x86-64"
+++

<div class="epigraph">
<p>Every byte in the running program was put there by a tool you invoked.</p>
<p class="attribution">— the rule, stated in advance, proved below</p>
</div>

Here is a short C program. Predict what it prints, then run it.

<div class="code-label">hello.c</div>

```c
#include <stdio.h>

int main(void) {
  printf("toolchain: 42\n");
  return 0;
}
```

Build it the ordinary way and run it:

```txt
$ gcc -O0 -g -Wall -Wextra -std=c11 tests/hello.c -o build/hello
$ ./build/hello
toolchain: 42
```

It prints `toolchain: 42` and the shell reports success. You can see why someone would stop here: one command in, one program out. The rest of this chapter shows what that one command did, in four stages you can each hold in your hand.

## Four stages, five artifacts

`gcc` is a driver. It runs other tools in order and hands each one's output to the next. Four flags stop the chain at each stage, and each stop leaves a file:

| Stage | Flag | Artifact | Bytes |
|---|---|---|---|
| Source | your editor | `hello.c` | 80 |
| Preprocess | `-E` | `hello.i` | 14,087 |
| Compile | `-S` | `hello.s` | 3,273 |
| Assemble | `-c` | `hello.o` | 3,544 |
| Link | no flag | `hello` | 13,624 |

Run each flag yourself; the lab's Makefile has a target per stage. Read the byte counts across: 80 bytes of source become 14,087 bytes of preprocessed text, then 3,273 bytes of assembly, then 3,544 bytes of object code, then a 13,624-byte program. Every byte came from somewhere: each row explains the next row's size.

Preprocessing pastes headers in. The 80 bytes you wrote become 14,087 because `stdio.h` arrives in full: the output names that header 37 times and carries its declarations, including line 379:

```c
extern int printf (const char *__restrict __format, ...);
```

Compilation translates C to assembly. The 208-line `hello.s` holds one surprise worth reading closely. Your source calls `printf`, but the assembly calls something else:

```asm
	movl	$.LC0, %edi
	call	puts
```

The compiler replaced your `printf` with `puts`. A format string with no conversions needs no formatting machinery, so the compiler emitted the simpler call. The program still prints exactly what you predicted. The tool may choose the simpler call as long as the output is unchanged.

Assembly turns text into machine code plus records. `file` confirms what `hello.o` is:

```txt
build/hello.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), with debug_info, not stripped
```

Relocatable means not yet placed: this object knows its own bytes but not yet where it will live. `size` counts those bytes by section: 139 text, 0 data, 0 bss. One hundred thirty-nine bytes of instructions; no globals, no zero-fill. On this build, at `-O0`, that is the whole compiled program.

Linking combines the object with the C library and fixes addresses. The result is executable and dynamically linked, with its interpreter named inside: `/lib64/ld-linux-x86-64.so.2`. Your 139 bytes of instructions now sit inside 13,624 bytes of program, most of it startup code and tables the linker added. That ratio is normal. Small sources ship inside larger programs.

## Read the bytes

A program on disk is bytes, and bytes can be read directly. The first sixteen bytes of `hello`:

```txt
$ xxd -l 16 build/hello
00000000: 7f45 4c46 0201 0100 0000 0000 0000 0000  .ELF............
```

Read the left column in pairs. `7f` is a control byte, then `45 4c 46` spells `ELF` in ASCII. `02` marks 64-bit, `01` marks little-endian. This layout is documented in `man 5 elf`, and every 64-bit little-endian Linux program starts with these same six bytes. Before the kernel runs a file, it checks this signature.

Bytes also answer how big C's types are, on this machine, under this compiler. The lab's second program prints exactly that:

```txt
$ ./build/sizes
char=1 int=4 long=8 ptr=8
```

One byte per `char`, four per `int`, eight per `long`, eight per pointer. These widths are the System V AMD64 ABI's choice. The C standard leaves each implementation to document its own (K&R Ch 2 says what the types promise; the ABI says what they measure). Portability bugs begin wherever someone assumes these numbers instead of measuring them. You just measured them.

## The shell keeps score

Every command you ran above ended with a status, and the shell kept each one. The variable `$?` holds the last command's exit status. Zero means the command reported success:

```txt
$ ./build/hello
toolchain: 42
$ echo $?
0
$ false
$ echo $?
1
```

`false` is a real command that does nothing and reports failure. Its `1` proves `$?` is a live reading, not decoration. Run each line above yourself. Then replace `false` with `true`, predict `$?` before you press enter, and confirm. POSIX documents `$?` as the previous command's exit status, and every build script in this book, including each lab's `check` target, stands on that variable. A gate that cannot distinguish pass from fail is decoration. The shell's score is what makes gates checkable.

**A program is built in stages, and each stage leaves a file you can read.** Preprocess, compile, assemble, link: four tools, five artifacts, every byte accounted for.

## Proof in three parts

<div class="proof">
  <div class="proof-block">
    <p class="proof-label">1 · The code</p>
    <p>The lab for this lesson, <code>labs/toolchain/</code>, holds the two programs (<code>hello.c</code>, <code>sizes.c</code>), a Makefile target per stage, and stage assertions: the preprocessed text must declare its function, the assembly must label <code>main</code>, the object must be relocatable, the binary executable.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">2 · The specification</p>
    <p>C11 §5.1.1.2 defines translation in eight phases. The four flags above stop that translation at four observable points. The standard describes the journey; the flags mark the stops.</p>
  </div>
  <div class="proof-block">
    <p class="proof-label">3 · The log</p>
    <p>This is the machine's answer. The lab gate checks both programs and every stage. Run <code>make -C labs/toolchain check</code> and match each VERIFIED line to its block.</p>
  </div>
</div>

```txt
VERIFIED ./build/hello
VERIFIED ./build/sizes
```

Two binaries verified, four stage assertions passed with no output because each held. Reference: GCC 16.2.1, `-O0 -g -Wall -Wextra -std=c11`, Fedora 44, x86-64, 2026-09-22.

## Practice

`labs/toolchain/` contains `hello.c`, `sizes.c`, and the stage Makefile. Your work:

1. Run `make -C labs/toolchain check` and confirm every line verifies on your machine.
2. Open `build/hello.s`, find the `main:` label, and read the body under it down to `ret`. Name the one that performs the call.
3. Delete the `#include` line, rebuild, and read the diagnostic. The compiler stops with `error: implicit declaration of function ‘printf’` and even suggests the missing line. Put it back.
4. Predict `sizeof` for `short`, then add it to `sizes.c` and run. If your prediction was wrong, find whether the standard or the ABI decides the real width.
5. Count the bytes at each stage with `wc -c` and compare against the table above. Same toolchain, same flags, same directory: same numbers. Debug info records the build path, so a different directory means different bytes.

Read in this order: K&R **Ch 2** ([where the types earn their names](https://9p.io/cm/cs/cbook/)), C11 **§5.1.1.2** ([where translation is defined](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf)), and `man 5 elf` ([where the signature is documented](https://man7.org/linux/man-pages/man5/elf.5.html)).

## What's next

Phase 1 takes up the program you just built: [Pointers and Lifetime](@/v0.1/phase-1-pointers/index.md). The stages above produce bytes; the next chapter asks how long each byte stays yours. Carry that question across — it is the whole of the next proof. The toolchain you met here is the instrument every later proof uses.

The rule, one last time: **every byte in the running program was put there by a tool you invoked.** Learn the tools in order, and any program opens the same way: stage by stage, file by file.

---

*Sources: C11 5.1.1.2; [K&R 2e](https://9p.io/cm/cs/cbook/) Ch 2; [`man 5 elf`](https://man7.org/linux/man-pages/man5/elf.5.html). Prose follows the classic style with a teaching voice (Thomas & Turner, *Clear and Simple as the Truth*): concrete first, mechanism before law; the machine judges.*
