CC      ?= gcc
CFLAGS  ?= -O0 -g -Wall -Wextra -std=c11

BUILDDIR = build

BINS     = hello sizes
TARGETS  = $(addprefix $(BUILDDIR)/,$(BINS))
STAGES   = $(BUILDDIR)/hello.i $(BUILDDIR)/hello.s $(BUILDDIR)/hello.o

all: $(TARGETS) $(STAGES)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/hello: tests/hello.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -o $@

$(BUILDDIR)/sizes: tests/sizes.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -o $@

$(BUILDDIR)/hello.i: tests/hello.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -E $< -o $@

$(BUILDDIR)/hello.s: tests/hello.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -S $< -o $@

$(BUILDDIR)/hello.o: tests/hello.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

check:
	$(MAKE) clean
	$(MAKE) all
	../../scripts/check-lab.sh . check.expectations
	test -s $(BUILDDIR)/hello.i && grep -q 'extern.*printf' $(BUILDDIR)/hello.i
	test -s $(BUILDDIR)/hello.s && grep -q '^main:' $(BUILDDIR)/hello.s
	file $(BUILDDIR)/hello.o | grep -q 'relocatable'
	file $(BUILDDIR)/hello | grep -q 'executable'

plain:
	$(MAKE) all

clean:
	rm -rf build

.PHONY: all check plain clean
