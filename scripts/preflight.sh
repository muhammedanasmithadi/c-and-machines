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

# Style gate: em-dash density. WRITING.md allows one per paragraph at most.
# Fenced code, inline code, and {% raw %} machine blocks are stripped first,
# so asm comments never trip the gate. Reports file:paragraph.
style_hits=$(python3 - <<'EOF'
import re, subprocess
files = subprocess.run(
    ['find', 'content', 'labs/malloc/notes', '-name', '*.md'],
    capture_output=True, text=True).stdout.split()
hits = []
for f in files:
    t = open(f).read()
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    t = re.sub(r'{% raw %}.*?{% endraw %}', '', t, flags=re.S)
    t = re.sub(r'`[^`]*`', '', t)
    for i, p in enumerate(re.split(r'\n\s*\n', t)):
        n = p.count('—')
        if n > 1:
            first = ' '.join(p.split())[:80]
            hits.append(f'{f} para {i}: {n} em-dashes: {first}...')
print('\n'.join(hits))
EOF
)
if [ -n "$style_hits" ]; then
  echo "preflight: >1 em-dash in a paragraph"
  echo "$style_hits" | sed 's/^/  /'
  fail=1
fi

# Shape watch (warnings only): not-X-but-Y needs human judgment, so the
# gate reports candidates without failing.
python3 - <<'EOF'
import re, subprocess
files = subprocess.run(
    ['find', 'content', 'labs/malloc/notes', '-name', '*.md'],
    capture_output=True, text=True).stdout.split()
pats = [r'not [^.?!]{3,80}\. (It is|That is|They are|This is)',
        r'(is|are) not [^.?!]{3,80};']
for f in files:
    t = open(f).read()
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    t = re.sub(r'{% raw %}.*?{% endraw %}', '', t, flags=re.S)
    t = re.sub(r'`[^`]*`', '', t)
    for pat in pats:
        for m in re.finditer(pat, t):
            print(f'  watch: {f}: ...{m.group(0)[:90]}...')
EOF

# Density info (never fails): total em-dashes per file, so drift shows
# before any paragraph breaks the rule.
python3 - <<'EOF'
import re, subprocess
files = subprocess.run(
    ['find', 'content', 'labs/malloc/notes', '-name', '*.md'],
    capture_output=True, text=True).stdout.split()
for f in files:
    t = open(f).read()
    t = re.sub(r'```.*?```', '', t, flags=re.S)
    t = re.sub(r'{% raw %}.*?{% endraw %}', '', t, flags=re.S)
    t = re.sub(r'`[^`]*`', '', t)
    n = t.count('—')
    if n:
        print(f'  info: {f}: {n} em-dashes in prose')
EOF

if [ "$fail" -ne 0 ]; then
  echo "preflight: FAILED"
  exit 1
fi
echo "preflight: clean"
