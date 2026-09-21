CC      ?= gcc
CFLAGS  ?= -O0 -g -Wall -Wextra -std=c11

ifneq ($(USE_ASAN),1)
  BUILDDIR   = build
  SAN        =
else
  BUILDDIR   = build-asan
  SAN        = -fsanitize=address,undefined -fno-omit-frame-pointer
endif

BINS     = leak doublefree dangling fixed epilogue
TARGETS  = $(addprefix $(BUILDDIR)/,$(BINS))

all: $(TARGETS)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/leak: tests/leak.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(SAN) $< -o $@

$(BUILDDIR)/doublefree: tests/doublefree.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(SAN) $< -o $@

$(BUILDDIR)/dangling: tests/dangling.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(SAN) $< -o $@

$(BUILDDIR)/fixed: tests/fixed.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(SAN) $< -o $@

$(BUILDDIR)/epilogue: tests/epilogue.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $< -o $@

check:
	$(MAKE) clean
	$(MAKE) all USE_ASAN=1
	../../scripts/check-lab.sh . check.expectations

plain:
	$(MAKE) all

clean:
	rm -rf build build-asan

.PHONY: all check plain clean