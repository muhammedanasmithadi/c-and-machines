#!/bin/sh
# Preflight: fail if book prose breaks the WRITING.md law.
#
# Scope is prose only: content/ pages plus lab notes. Fenced code blocks and
# inline code are stripped first, so verbatim machine logs (e.g. "leak: phantom")
# never trip the gate. WRITING.md itself names the banned words, so it stays
# out of scope. The word list lives in WRITING.md ("Mechanical gates").
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

# Module law gate: every module page declares a one-sentence extra.law.
# Module pages are content/v0.1/phase-*/<module>/index.md plus the single-page
# Phase 0 (phase-0-toolchain/index.md). Phase hubs (_index.md) are exempt.
python3 - <<'EOF'
import re, subprocess, sys
files = subprocess.run(
    ['find', 'content/v0.1', '-name', 'index.md'],
    capture_output=True, text=True).stdout.split()
fail = False
for f in files:
    if f.endswith('/_index.md'):
        continue
    parts = f.split('/')
    # content/v0.1/phase-X/index.md is the phase page itself (Phase 0, or a
    # hub-shaped page kept for compatibility): Phase 0 must carry a law.
    is_phase_root = len(parts) == 4
    is_module = len(parts) == 5
    if not (is_phase_root or is_module):
        continue
    if 'phase-0-toolchain' not in f and not is_module:
        continue
    t = open(f).read()
    m = re.search(r'^law\s*=\s*"(.*)"', t, flags=re.M)
    if not m:
        print(f'preflight: missing extra.law in {f}')
        fail = True
        continue
    law = m.group(1).strip()
    if not law or law.count(';') > 0 or len(law.split()) < 4:
        print(f'preflight: law not one sentence in {f}: {law[:80]}')
        fail = True
sys.exit(1 if fail else 0)
EOF
if [ "$?" -ne 0 ]; then
  fail=1
fi

# First-40-lines gate: no later-phase machinery, no canon, no scavenger hunt
# before the model exists. Counts raw body lines (after frontmatter), so any
# author can verify by line number. Inline code is kept: naming popq in
# backticks on line 10 is still naming it on line 10.
# Note: QEMU is deliberately absent from this list. Phase 2A runs QEMU as its
# concrete second run, so a global ban would forbid the artifact itself. The
# per-module frontmatter (docs/module-template.md) still declares QEMU
# forbidden for 1A/1B, enforced in review.
module_hits=$(python3 - <<'EOF'
import re, subprocess
files = subprocess.run(
    ['find', 'content/v0.1', '-name', 'index.md'],
    capture_output=True, text=True).stdout.split()
forbidden = ['popq', 'retq', 'pop %rbp', 'bti c', 'BTI',
             'AddressSanitizer', 'Valgrind',
             'two-gate', 'two gate', 'primary gate',
             'find the reading', 'in the list above',
             'match each step to its section',
             'match each of the three to its row',
             'read the standard first', 'read N1570 first']
hits = []
for f in files:
    if f.endswith('/_index.md'):
        continue
    t = open(f).read()
    # frontmatter ends at the second +++
    body = t.split('+++', 2)[-1] if t.startswith('+++') else t
    first40 = '\n'.join(body.splitlines()[:40])
    low = first40.lower()
    for term in forbidden:
        if term.lower() in low:
            idx = low.index(term.lower())
            ctx = first40[max(0, idx-30):idx+40].replace('\n', ' ')
            hits.append(f'{f}: forbidden in first 40 lines: "{term}" ...{ctx}...')
            break
print('\n'.join(hits))
EOF
)
if [ -n "$module_hits" ]; then
  echo "preflight: first-40-lines violation"
  echo "$module_hits" | sed 's/^/  /'
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "preflight: FAILED"
  exit 1
fi
echo "preflight: clean"
