# WRITING.md — How this book is written

This file is the prose law for **every** lesson, lab, and chapter in *C and Machines*.

Classic style omits scaffolding so the truth feels self-evident. This book's
reader does not yet have the scaffolding. We write so a novice can build a
schema, then check it on the machine.

If a page fights this file, the page is wrong.

## The philosophy, in four sentences

1. **The machine is the judge.** A claim is finished when the reader can run it and read the log. The author's voice is not evidence.
2. **One lesson is one law.** If the reader cannot retrieve the law tomorrow in one sentence, you have two lessons.
3. **Show a live case, then the mechanism, then the law.** Names first, safe example, twist, run, *because*, one sentence, then the broken variant.
4. **The reader must produce.** Predicting, marking a line, filling a table from memory, and patching a hole in a worked example are the lesson. Witnessing prose is not.

Keep: short sentences, "you," dry exactness, labs, both ISAs, the six-step skeleton.
Stop: atmosphere before the model, aphorisms instead of *because*, future chapter machinery, citation purity tests, a second law on the same page.

## Who we are writing for

A reader who can type, run a compiler, and be wrong in public. They have not yet got:

- a durable picture of lifetime, the toolchain, or a calling convention
- the habit of reading a listing before arguing with C
- the standard as a working tool

Write for that reader on page one of every module. Experts can skip. Novices cannot invent glue you omitted.

## The order (fixed)

Every teaching module uses this order. Empty steps mean the module is not done.

1. **Pre-train names** — at most five. One line or one table row each. Same word every time after that.
2. **Safe concrete case** — a short program that *obeys* the law. The reader can predict it.
3. **A small twist** — one change. Ask for a prediction. They write it down.
4. **Run** — the machine answers. Both outcomes (crash, garbage, 7) are data.
5. **Mechanism** — how the machine actually behaves. Use *because / so / therefore*.
6. **The law** — one sentence, retrieveable tomorrow. Typographically marked.
7. **Broken variant** — undefined behavior, the wrong lifetime, the missing `free`. *Here*, not in step 2.
8. **One table or one listing** — labels on the thing they name, next to it, not three screens away.
9. **Completion** — a hole in a worked example (change `+` to `-`; add `sizeof short`; call `winner` twice).
10. **Retrieval** — close the page; write the law; write why the broken variant fails.
11. **The standard, after** — section number and the sentence to look for. Never as first instruction.

The public six-step shape (artifact, run, mechanism, law, proof, practice) is this order, named for the reader. Do not skip steps 1, 7, 10, or 11 in the draft just because the public list is shorter.

## The law sentence

- One per module.
- A sentence the reader can say aloud without the page.
- A rule about the machine or the language, not a mood.

Good: **A pointer is valid only while the object it names is alive.**
Good: **Every byte in the built program was put there by the toolchain.**
Good: **The C source is not what runs; the listing is.**

Bad: "The machine keeps the books." (metaphor, not a testable rule)
Bad: two laws joined by a semicolon.
Bad: a law that requires a term taught two chapters later.

State the law once at the top as a promise, prove it, state it once at the end as something to retrieve. Not three slogans and no mechanism.

## Voice

Sound like this:

> When `winner` returns, `local` is gone, so the address in `w` does not name an object anymore. The next read is undefined. GCC turned that address into NULL; Clang left the old bits. Both are allowed.

Do not sound like this:

> Break one, and the program may crash, print garbage — or print the right answer, with the debt still on the books.

The first is exact and causal. The second is classic style: a scene that requires the schema it is supposed to teach.

Rules:

- Address the reader as **you**.
- Prefer active verbs and visible agents (`gcc` pastes, the block exits, `free` returns the block).
- Same name for the same thing. Pick *object* or *slot* or *storage*; do not hop.
- One idea per paragraph. First sentence is the claim.
- Wit is allowed only after the mechanism, one line, as a memory hook — never as the explanation.
- No jokes, no memes, no "fun facts" that do not carry the law. Interesting irrelevance is extra load.
- No moralizing about sources, tools, or other books on a teaching page.
- Imperative mood for instructions to the reader ("Run the suite:", "Fix the three files").
- Declarative mood for what the machine does ("The allocator reclaims blocks only when told.").
- Present tense throughout. The book describes how things work now, on the machine the reader has.
- Vary the rhythm. Short sentences for weight. Long sentences for texture. A chapter made entirely of staccato lines reads like a field manual in a hurry; a chapter made entirely of long lines reads like a rumor.

## Forbidden in the first 40 lines of a module

- A metaphor that will not be used as the model on that page.
- A compiler war (GCC vs Clang vs `-O2`) before the law exists.
- Assembly from a later phase (`popq`, `retq`, BTI, PIE).
- A citation purity rule, a build-lore paragraph, a dateline essay.
- "Read the standard first."
- A scavenger hunt ("find three readings in the list above").
- A second law.

Datelines, reference builds, and ISA footnotes belong after the run, or in a colophon.

## Proof in three parts (what each part is for)

1. **The code** — the lab files the reader will run. Named. Short.
2. **The specification** — the sentence in the standard, the ABI, or `man`, quoted *after* they have seen the behavior.
3. **The log** — **one** stanza that proves *this* law. Mask pids if you must. Do not paste four ISAs, ASan, and Valgrind into the teaching column.

Everything else is an **appendix**: other compilers, other ISAs, full traces, "run this by hand for the register dump." Appendices are honest. They are not the lesson.

## Practice (every module)

Three items, no more required, no fewer:

| Kind | What it is | Example |
|---|---|---|
| Retrieve | Law from memory | "Write the lifetime law. Do not look." |
| Complete | Hole in a worked example | "Change `+` to `-`. Name the instruction that must change in each listing." |
| Transfer | One new case | "Call static `winner` twice. Do the addresses match? Why?" |

Delete treasure hunts. Delete "match this list to a later chapter." Stretch ISA / sanitizer work is allowed as an optional fourth item, labeled stretch.

## Sources

This book *cites* primary sources. It does not *teach by handing a novice the standard*.

- **Read with this lesson** — one chapter or one section, and *what to look for*, placed after the lab.
- **Shelf** — K&R, CS:APP, Kerrisk, Intel SDM, and the rest. Linked from the back of the book, not from hello world.

Two sentences from C11 §6.2.4 after a dangling pointer has crashed are teaching.
N1570 as the first homework is not.

Two gates admit a source. Primary gate: the artifact itself (a standard, a measurement) from the person who made it. Public gate: two or more independent university adoptions, or sustained technical praise with specifics. Never popularity.

## Across chapters (fading, not dumping)

- Start concrete, then strip to the law, then a second case that *looks different* (a heap object, the other ISA).
- Worked example first, then a hole, then they write it.
- A later chapter may *pay off* an earlier one (Phase 2 shows the teardown lines where Phase 1's `local` died). Name the old law; do not assume it.
- When the reader has the schema, you may leave a small inference gap. Until then, write the *because*.

## Homepage and front matter

The first screen of the book is a teaching page.

It contains: what they will be able to **do**, the phase table, start here (Phase 0, ten minutes), how a module works.

It does not contain: promises/debt metaphors, "almost nothing rests on the author's word," two-gate canon, `jj` bookmarks, tool ownership, scavenger hunts.

Build lore and philosophy may live under **How this book is made**, below the fold.

## Module frontmatter (required)

Every teaching file carries this. If a field is empty, the module is not done.

```text
module_id:
law:                         # one sentence
pretrain:                    # ≤ 5 terms
forbidden_first_40_lines:    # terms and topics that must not appear yet
opener:                      # safe case, or one-step twist on the previous module
worked_example:              # one listing or one table
counterexample:              # broken variant (UB lives here)
proof:
  spec:
  code:
  log:                       # one stanza
practice:
  retrieve:
  complete:
  transfer:
read_after:                  # source, section, look-for
appendix:                    # other ISAs, other tools
```

In Zola this maps to `[extra]`: `module_id`, `law`, `pretrain`, `order`. Review question: **does every paragraph earn its place in this law?** If not, move it or delete it.

## Review checklist (use on every page)

1. One law?
2. Terms defined before use?
3. Safe case before the bug?
4. *Because* written, not implied?
5. Same word for the same concept?
6. Labels on the listing?
7. One log, not a museum?
8. Reader produces (predict / retrieve / patch)?
9. Standard after the schema?
10. First 40 lines clean of metaphor, future assembly, and canon?

If any answer is no, the page is not done.

## What we are not doing

- Matching "learning styles."
- Making fonts harder.
- Adding decorative stories so it "sticks."
- Unguided discovery through the standard.
- Academic fog as rigor.
- Classic style as rigor.

Rigor here is: a law you can retrieve, a program you can run, a log you can read.

## The test

A new reader who has written a little C, not a compiler:

1. Starts Phase 0 in ten minutes without N1570.
2. Can write, from memory, each module's law they have finished.
3. Meets undefined behavior *after* a live example that worked.
4. Sees `pop %rbp` for the first time on the same page as "this is where `local` dies."
5. Never hits a scavenger hunt.
6. Still hears this book: short, exact, machine-first.

If those six hold on every lesson, this file is being followed.

## Mechanical gates (preflight-enforced)

The teaching voice above is enforced by `scripts/preflight.sh`. This section
lists the literal gates so the script and this file cannot drift apart.

- **No drama words.** die, dies, died, 3 AM, moods, lore, phantom, magic. The machine crashes; it does not die. It prints; it does not explain. Fenced code blocks and inline code are stripped before the check, so verbatim machine logs never trip the gate. WRITING.md itself names the banned words, so it stays out of scope.
- **One em-dash per paragraph at most.** Sentence length is the rhythm: some spare, some full, some routine. If the sentence after the dash can stand alone, give it a period instead.
- **No triadic slogans.** "X, Y, one Z" or "Two A, two B, one C."
- **No not-X-but-Y openers.** "This is not a quirk. It is the definition." State the fact; let it answer the reader's question.
- **No sermon-you.** The reader is the student, not the accused.
- **No absolute white/black thinking.** Say which it is, with evidence.
- **No personification.** The machine does not "want", "decide", or "refuse". It *is* in a state and *does* what the hardware does.
- **No repeated slogans.** State the law once at the top as a promise, prove it, state it once at the end as something to retrieve. In between, plain prose.
- **Terminology under oath.** Functions are not operators; frames exist only while their function runs; "deterministic" names a build, not a language. Vocabulary errors break the contract faster than anything else.
- **Every claim has an artifact.** Never claim a trace you have not run. Every log line in the book has a committed provenance: the command, the compiler, the date.
- **Every page must run on a stranger's machine.** Relative links, pinned versions, dateline intact. Verify through the public URL, never localhost.
- **Metaphors must be earned.** Introduce a metaphor by its mechanism once, then it may recur freely. One metaphor system per paragraph. If deleting a metaphor would not change the model, delete it.
- **Facts, citations, and honesty.** Cite primary sources by name and location. Tell the reader which page or section and why you rest on it. If a claim comes from a person or a source with a known limit, say so.
