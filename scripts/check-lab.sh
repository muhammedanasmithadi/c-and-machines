#!/bin/sh
# check-lab — expectation-driven acceptance for native labs.
#
# Root-cause design (audit finding A01):
#   The old gate's success condition was "the recipe exited 0", decoupled from
#   whether anything expected was verified. This checker separates:
#     expectations (declared per fixture) -> observation (status + output) -> verdict
#   and refuses to pass unless every expectation is VERIFIED. It also carries a
#   self-test that must reject forged passes, so the checker itself is gated.
#
# Expectations file format (one per line, '|' separated):
#   binary-name|ok|ERE-pattern       success status AND output matches ERE
#   binary-name|fail|ERE-pattern     nonzero status AND output matches ERE
#   binary-name|fail|-               nonzero status, any output
#   binary-name|ok|-                 success status, any output
# Lines starting '#' and blank lines are ignored. Missing executables, timeouts
# and shell-exec failures are always verdict failures, never passes.
set -u
TIMEOUT_SECS=${TIMEOUT_SECS:-30}

verdict() { # $1 binary  $2 class  $3 pattern  -> prints verdict tag
  if [ ! -x "$1" ]; then printf 'MISSING-TOOL %s\n' "$1"; return; fi
  st=0
  out=$(timeout "$TIMEOUT_SECS" "$1" 2>&1) || st=$?
  if [ "$st" -eq 124 ] || [ "$st" -eq 137 ]; then printf 'TIMEOUT %s\n' "$1"; return; fi
  if [ "$st" -eq 126 ] || [ "$st" -eq 127 ]; then printf 'MISSING-TOOL %s\n' "$1"; return; fi
  case "$2" in
    ok)  if [ "$st" -ne 0 ]; then printf 'WRONG-STATUS %s exit=%s\n' "$1" "$st"; return; fi ;;
    fail) if [ "$st" -eq 0 ]; then printf 'EXPECTED-FAILURE-ABSENT %s\n' "$1"; return; fi ;;
    *) printf 'BAD-EXPECTATION %s class=%s\n' "$1" "$2"; return ;;
  esac
  if [ "$3" != '-' ] && ! printf '%s\n' "$out" | grep -Eq -- "$3"; then
    printf 'DIAGNOSTIC-MISSING %s pattern=%s\n' "$1" "$3"; return
  fi
  printf 'VERIFIED %s\n' "$1"
}

scan() { # $1 lab-dir  $2 expectations file -> 0 iff every line VERIFIED
  [ -f "$2" ] || { printf 'check-lab: no expectations file %s\n' "$2" >&2; return 2; }
  rc=0
  while IFS='|' read -r name cls pat; do
    case "$name" in ''|'#'*) continue ;; esac
    v=$(verdict "$1/$name" "$cls" "${pat:--}")
    printf '%s\n' "$v"
    case "$v" in VERIFIED*) ;; *) rc=1 ;; esac
  done < "$2"
  return "$rc"
}

self_test() { # checker must classify all five forged/real fixtures correctly
  d=$(mktemp -d) || return 2
  trap 'rm -rf "$d"' EXIT HUP INT TERM
  printf '#!/bin/sh\nexit 0\n'                        > "$d/ok-bin"
  printf '#!/bin/sh\necho "AddressSanitizer: double-free"\nexit 1\n' > "$d/fail-bin"
  printf '#!/bin/sh\necho "unrelated failure"\nexit 1\n'             > "$d/wrongmsg-bin"
  printf '#!/bin/sh\nexit 0\n'                        > "$d/stub-bin"
  chmod +x "$d/ok-bin" "$d/fail-bin" "$d/wrongmsg-bin" "$d/stub-bin"
  printf 'ok-bin|ok|-\nfail-bin|fail|double-free\nwrongmsg-bin|fail|double-free\nstub-bin|fail|double-free\nabsent-bin|fail|-\n' > "$d/exp"
  out=$(scan "$d" "$d/exp"); rc=$?
  printf '%s\n' "$out"
  printf '%s\n' "$out" | grep -q '^VERIFIED .*ok-bin$'      || { echo 'SELFTEST: ok fixture misjudged'; return 1; }
  printf '%s\n' "$out" | grep -q '^VERIFIED .*fail-bin$'    || { echo 'SELFTEST: real failure misjudged'; return 1; }
  printf '%s\n' "$out" | grep -q '^DIAGNOSTIC-MISSING'      || { echo 'SELFTEST: wrong diagnostic accepted'; return 1; }
  printf '%s\n' "$out" | grep -q '^EXPECTED-FAILURE-ABSENT' || { echo 'SELFTEST: silent stub accepted'; return 1; }
  printf '%s\n' "$out" | grep -q '^MISSING-TOOL'            || { echo 'SELFTEST: missing tool accepted'; return 1; }
  [ "$rc" -ne 0 ]                                            || { echo 'SELFTEST: forged set passed overall'; return 1; }
  # A fully correct expectation set must pass overall.
  printf 'ok-bin|ok|-\nfail-bin|fail|double-free\n' > "$d/exp2"
  scan "$d" "$d/exp2" >/dev/null || { echo 'SELFTEST: correct set failed overall'; return 1; }
  echo 'SELFTEST: checker rejects forged passes and accepts honest results'
}

case "${1:-}" in
  --self-test) self_test ;;
  '') printf 'usage: check-lab <lab-dir> [expectations-file]\n       check-lab --self-test\n' >&2; exit 2 ;;
  *)  lab=$1; exp=${2:-$lab/check.expectations}; scan "$lab" "$exp" ;;
esac
