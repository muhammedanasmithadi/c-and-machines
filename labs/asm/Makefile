CC      ?= gcc
CFLAGS  ?= -O0 -g -Wall -Wextra -std=c11

# Cross leg (AArch64 via QEMU). The populated sysroot lives under
# aarch64-redhat-linux on Fedora; override QSYSROOT if yours differs.
ACROSS   = aarch64-linux-gnu-gcc
QEMU     = qemu-aarch64
QSYSROOT ?= /usr/aarch64-redhat-linux/sys-root/fc44
AFLAGS   = $(CFLAGS) --sysroot=$(QSYSROOT)
# Fedora's cross driver asks the linker for -latomic_asneeded, a stub the
# distro does not ship for aarch64. lib/libatomic_asneeded.a is an empty
# archive (verify: `ar t` lists no members), so it satisfies the flag while
# contributing nothing to the binary.
# The populated sysroot keeps its loader at /usr/lib, while the driver's
# default interpreter is /lib: name it explicitly so QEMU's -L mapping
# resolves. Both paths name the same file on a real Fedora install
# (/lib is a symlink to usr/lib there).
# The populated sysroot keeps its loader at /usr/lib, while the driver's
# default interpreter is /lib: name it explicitly so QEMU's -L mapping
# resolves. Both paths name the same file on a real Fedora install
# (/lib is a symlink to usr/lib there).
ALDFLAGS = -L$(CURDIR)/lib -Wl,--dynamic-linker=/usr/lib/ld-linux-aarch64.so.1 -Wl,--dynamic-linker=/usr/lib/ld-linux-aarch64.so.1

BUILDDIR  = build
ABUILDDIR = build-aarch64

all: $(BUILDDIR)/add $(ABUILDDIR)/add $(BUILDDIR)/add.s $(ABUILDDIR)/add.s

$(BUILDDIR) $(ABUILDDIR):
	mkdir -p $@

$(BUILDDIR)/add: tests/add.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -o $@

$(ABUILDDIR)/add: tests/add.c | $(ABUILDDIR)
	$(ACROSS) $(AFLAGS) $< $(ALDFLAGS) -o $@

$(BUILDDIR)/add.s: tests/add.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -S $< -o $@

$(ABUILDDIR)/add.s: tests/add.c | $(ABUILDDIR)
	$(ACROSS) $(AFLAGS) -S $< -o $@

check:
	$(MAKE) clean
	$(MAKE) all
	../../scripts/check-lab.sh . check.expectations
	$(QEMU) -L $(QSYSROOT) $(ABUILDDIR)/add | grep -q 'add: 42'
	test -s $(BUILDDIR)/add.s && grep -q '^add:' $(BUILDDIR)/add.s
	test -s $(ABUILDDIR)/add.s && grep -q '^add:' $(ABUILDDIR)/add.s

plain:
	$(MAKE) all

clean:
	rm -rf build build-aarch64

.PHONY: all check plain clean
