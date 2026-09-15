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

run = sh -c '{ ./build-asan/$$0 2>&1 | grep -E "ERROR:|SUMMARY:|runtime error:|\bABORTING|in main tests|is located|freed by|previously allocated|Direct leak|leak of |The signal|Hint:" ; exit $${PIPESTATUS[0]} ; }'

check:
	$(MAKE) all USE_ASAN=1
	@echo "== leak (expect failure) ==";     $(run) leak     && echo "leak NOT detected"     || echo "leak detected"
	@echo "== doublefree (expect failure) =="; $(run) doublefree && echo "double-free NOT detected" || echo "double-free detected"
	@echo "== dangling (expect failure) =="; $(run) dangling  && echo "dangling NOT detected" || echo "dangling detected"
	@echo "== fixed (expect PASS) =="; ./build-asan/fixed && echo "fixed PASSED"

plain:
	$(MAKE) all

clean:
	rm -rf build build-asan

.PHONY: all check plain clean