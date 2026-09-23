# Module template

Every teaching module in *C and Machines* uses this shape. If a field is
empty, the module is not done. See WRITING.md for the law behind each line.

```text
module_id: 1B
law: A pointer is valid only while the object it names is alive.
pretrain:
  - object
  - address
  - pointer
  - lifetime
  - automatic storage
forbidden_first_40_lines:
  - popq/retq
  - ASan
  - Valgrind
  - QEMU
  - a second law
opener: a program that currently obeys the law  OR  a 1-step twist on the previous module
worked_example: one listing OR one table, labels on the thing
counterexample: the broken variant (UB lives here)
proof_spec: C11 §6.2.4 two sentences, after the run
proof_code: labs/malloc/tests/dangling.c
proof_log: one ASan stanza
practice_retrieve: the law
practice_complete: hole in the worked example
practice_transfer: one new case
read_after:
  - source, section, "look for this sentence"
appendix:
  - other ISAs
  - other sanitizers
```

## Zola mapping

Frontmatter on each module page carries the machine-checkable subset:

```toml
[extra]
module_id = "1B"
law = "A pointer is valid only while the object it names is alive."
pretrain = ["object", "address", "pointer", "lifetime", "automatic storage"]
order = 2
```

- `law` is one sentence. A semicolon-joined double law fails preflight.
- `pretrain` holds at most five terms.
- `order` sorts modules on the phase hub.
- The remaining keys (`forbidden_first_40_lines`, `opener`, `worked_example`,
  `counterexample`, `proof_spec`, `proof_code`, `proof_log`,
  `practice_retrieve`, `practice_complete`, `practice_transfer`,
  `read_after`, `appendix`) carry the template one line per key, so the file
  and WRITING.md compare mechanically.
- The homepage six-step list stays as the reader-facing shape. This template
  is the enforcement of "one law."
