# WRITING.md — the book's prose standard

This file governs prose in `content/`, lab notes, and any other text the
reader will read. It is the contract for how we write, in the same way the
lab Makefile is the contract for how we build.

## The one requirement

The reader must be able to check everything. Prose is the scaffold around
concrete artifacts: runnable code, the machine's log, the standard's words.
If a claim has no artifact behind it, cut it or find the artifact.

## The classic style

We write in the classic style, as described by Francis-Noël Thomas and Mark
Turner in *Clear and Simple as the Truth*:

- **Write to somebody.** A reader who is smart, curious, and new to the
  subject. Never write to yourself, never write to a committee.
- **Testimony and description.** The machine's log is testimony; what the
  mechanism does is description. Both use plain, specific words.
- **Concrete first.** Open with a program, a number, a register, a log line.
  Abstraction earns its place afterward, and only as it serves the concrete.
  A one-line epigraph is allowed to state the rule in advance, provided the
  concrete artifact that proves it opens the next paragraph.
- **Mechanism before law.** Show how something works before you state the
  rule. A rule with no mechanism underneath is magic.
- **One analogy at most, and it must be spec-true.** An analogy must not
  survive past the point where the mechanism differs from it. When in doubt,
  drop the analogy and name the mechanism.
- **Plain vocabulary.** Use the shortest honest word. Jargon is allowed where
  it is the real name of the thing, and only after it is introduced.
- **No personification.** The machine does not "want", "decide", or "refuse".
  It *is* in a state and *does* what the hardware does. Personification is
  lazy prose hiding a lazy model.
- **Vary the rhythm.** Short sentences for weight. Long sentences for texture.
  A chapter made entirely of staccato lines reads like a field manual in a
  hurry; a chapter made entirely of long lines reads like a rumor.
- **The machine judges.** Every chapter ends with the reader able to run
  something and watch the machine agree or disagree.

## The teaching voice

The classic style keeps the prose honest, but it does not by itself make the
prose teach. Teaching prose shows the reader's starting point, then moves
toward the artifact. The reader is smart, curious, and new to the subject;
the text walks beside them, not above them.

- **Open with the reader's likely mental model.** "You can see why someone
  would read this as X." Then the artifact answers.
- **Check every mental model against the artifact.** When the model is
  wrong, the machine's output is what says so — the text just looks at it.
- **Ask a question only when an artifact answers it next.** Never leave a
  question hanging.
- **Use "we" for the teacher and the reader together.** "We compile, we
  run, we read the verdict." A direct "you" is fine for an instruction ("Run
  the suite"), not for a sermon.
- **State one sharp rule per section.** One. A second rule sentence makes
  the first sound like decoration.
- **Give the reader a job in every section.** Predict, run, read, fix. The
  book says what to look at; the reader looks.

Forbidden patterns. They read as advertisement, prophecy, or decided-in-a-
doc:

- **No triadic slogans.** "X, Y, one Z" or "Two A, two B, one C." Real
  writing does not countenance.
- **No not-X-but-Y openers.** "This is not a quirk. It is the definition."
  State the fact; let it answer the reader's question.
- **No absolute white/black thinking.** "None of these is a logic bug."
  Say which it is, with evidence.
- **No sermon-you.** "Your code either obeys it or the assertions fail on
  you." The reader is the student, not the accused.
- **No drama words.** die, 3 AM, moods, lore, phantom, magic. The machine
  crashes; it does not die. It prints; it does not explain. A failure at
  three in the morning is a real thing a student may face, but it is a
  deployed-software fact, not a scare.
- **No repeated slogans.** The epigraph may say it once in advance; the
  closing may name it once more. In between, plain prose.
- **One em-dash per paragraph at most.** Sentence length is the rhythm:
  some spare, some full, some routine. Do not machine-gun the dashes.

## Full articulation

This book is not a telegram, a slide, or a chat reply. It is at leisure to
use relative clauses, subordinate clauses, and every tool an articulate
writer has. Where the chat interface saves words, the book spends them to
achieve clarity and cadence. Write at the reader's service, not at the
rhythm of a terminal.

## The machine voice

Machine state, tools, and verdicts are rendered in the mono typeface; prose
is serif. The CSS already enforces this separation. Do not describe machine
output when you can show it.

## Voice and register

- Imperative mood for instructions to the reader ("Run the suite:", "Fix the
  three files").
- Declarative mood for what the machine does ("The allocator reclaims blocks
  only when told.").
- Present tense throughout. The book describes how things work now, on the
  machine the reader has.

## What a module must contain

Every module (chapter, section, lab section) follows the six-step shape stated
on the home page:

1. A concrete artifact opens it.
2. It is played forward.
3. The mechanism underneath is shown.
4. A rule lands in one sharp sentence.
5. Proof has three parts: specification, runnable code, machine log.
6. Practice closes it.

## Facts, citations, and honesty

- Cite primary sources by name and location (K&R 2e Ch 5-6, CS:APP 3e §9.9).
- Tell the reader *which* page or section and *why* you rest on it.
- If a claim comes from a person or a source with a known limit, say so.
- Never claim a trace you have not run. Every log line in the book has a
  committed provenance: the command, the compiler, the date.

## The two-gate rule for sources

A source must pass one of two gates:

- **Primary:** a researcher, academic, or standards author with a primary
  artifact and a measurement.
- **Public:** two or more independent university adoptions, or sustained
  technical praise with specifics — never influencer applause.

## Reading order

Prose is written to be read in order, top to bottom, as in a book. If a
reader can skip a paragraph without losing the argument, either the paragraph
is irrelevant or the chapter's structure has failed.

## Style checklist (pre-ship)

- [ ] Every claim has an artifact: code, log, or standard quote.
- [ ] Concrete first — no chapter opens with a law (a proved epigraph excepted).
- [ ] At most one spec-true analogy per argument.
- [ ] No personification of the machine.
- [ ] Every trace is real and reproducible.
- [ ] Rhythm varies; no wall of staccato, no wall of long lines.
- [ ] Prose runs top-to-bottom; nothing is skippable without cost.
- [ ] An articulate voice, at the reader's service.
- [ ] No triadic slogans, no not-X-but-Y openers, no sermon-you.
- [ ] No drama words (die, 3 AM, moods, lore, phantom, magic).
- [ ] At most one em-dash per paragraph.
- [ ] One sharp rule sentence per section.
- [ ] The reader has a job in every section: predict, run, read, fix.