#!/bin/sh
# Preflight: fail if book prose uses a banned voice word.
#
# Scope is prose only: content/ pages plus lab notes. Fenced code blocks and
# inline code are stripped first, so verbatim machine logs (e.g. "leak: phantom")
# never trip the gate. WRITING.md itself names the banned words, so it stays
# out of scope. The word list lives in WRITING.md ("The teaching voice").
set -eu
cd "$(dirname "$0")/.."

PATTERN='\b(die|dies|died|moods?|lore|phantom|magic|3 ?a\.?m\.?)\b'

strip_code() {
  awk 'BEGIN{f=0} /^[[:space:]]*```/{f=!f; next} !f{print}' "$1" \
    | sed 's/`[^`]*`//g'
}

fail=0
for f in $(find content labs/malloc/notes -name '*.md'); do
  hits=$(strip_code "$f" | grep -nEi "$PATTERN" || true)
  if [ -n "$hits" ]; then
    echo "preflight: banned word in $f"
    echo "$hits" | sed 's/^/  /'
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "preflight: FAILED"
  exit 1
fi
echo "preflight: clean"
