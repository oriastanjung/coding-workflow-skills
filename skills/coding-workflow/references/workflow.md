# Workflow

One stacked PR per **vertical slice**. Not one per file, and not one branch for
a whole phase. Work the stack slice by slice, one PR at a time, until every
gate has passed for every slice.

## Loop per slice

1. `gh stack sync`, then `gh stack add <slice-branch>`.
2. Open the slice's PR as a draft before any code (`create-pr.md`). Set the
   slice's ticket to In Progress with the PR link
   (`write-or-update-ticket.md`).
3. Build the slice through one **Haiku implementor subagent** (see "Who does
   what" in `SKILL.md`). Brief it with the slice's steps from the plan as a
   task list, each test its own item, tests for every level the slice
   reaches (`test-levels.md`), the exact files and the gate commands. It
   edits and runs commands only; no git, no `gh`. When it reports, read its
   diff; when the code forced it off the plan, log that under "Changes
   during build". Then you commit the slice's paths, `gh stack submit`, and
   post a progress comment on the PR.
4. Review round: you review the diff yourself against `pr-review.md`'s
   prompt and post the report on the PR. Faults go back to the same or a new
   Haiku subagent as a fix brief; you commit, submit, and review again. Stop
   when the verdict is SHIP.
5. Gate: run `lint`, `typecheck`, `test`, `build`, `test:e2e`, and post the raw
   output on the PR. Anything red: fix, push, new review round.
6. Prove the slice, posting each part on the PR:
   - **Against the plan.** Hold the slice in `$WORK/plan.md` next to
     `git diff <base-branch>...HEAD`. Every "done when" item: met, and by
     what. Every step: built, or dropped with a reason. Every changed file:
     in the plan, explained under "Changes during build", or reverted.
   - **As a user.** Run the app and go through the slice the way a user
     would. With a screen: Playwright in a real browser, through setup and at
     least one failure, with red-boxed stills (`proof-capture.md`). Without a
     screen: the command and its output.
   - **Tidy up.** Stop servers you started, delete scratch files and debug
     prints, and make sure `git status` lists only this slice.

   Found a bug while proving? Fix it, review again, gate again, capture again.
   Proof must come from the final code.
7. Write the full PR body (`create-pr.md`), upload the proof and check that it
   plays (`proof-capture.md`). Then `gh pr ready <number>` and set the ticket
   to In Review.
8. Merge, `gh stack sync`, set the ticket to Done with a comment that links
   the PR.
9. Go to the next slice. Stop only when the last slice is merged.

## Running e2e

Report the real output. Never summarise a failure as a pass, and never declare
a slice done on red.

**Only ONE e2e run at a time, across the whole session.** The suite runs
`--runInBand` against one shared database. Two concurrent runs delete each
other's fixtures mid-flight, which looks exactly like real bugs: intermittent,
not reproducible alone, and hours lost chasing them. Before an e2e run, check
for a live one and wait for it to clear:

```bash
pgrep -af "jest.*jest-e2e" | grep -v "bash -c"
```

The `grep -v` is required: the guard's own shell contains the pattern, so a
bare `pgrep` matches itself and reports busy forever.

Never background an e2e run and keep working. Before killing a long-running
jest process, check whether its results are already printed: a finished suite
can leave the process sleeping for minutes, and killing that loses nothing,
while killing a run in flight wastes the whole pass.

## Two ways a test lies

**Green when the guard is gone.** Delete each guard in turn and confirm a test
fails. Defence in depth can hide a guard: a different guard upstream stops the
case before it reaches the one the test is named for. Only mutation shows it.

**Red when nothing is wrong.** A "this secret does not appear" assertion must
assert **the secret**, not a shape like it. A generic digit regex fires on ids:
a uuidv7's last segment is twelve digits, so `/\d{12}/` reports a leak on a
correctly masked body. A rare false alarm is worse than a frequent one: it gets
diagnosed as a real leak before anyone suspects the test.

For a response-shape assertion, prefer **equality on the key set** over a
negative list, so a new field fails the test instead of slipping past.

## Fix iterations

Every fixing iteration gets one code comment that explains the *why* of the
fix: the hidden constraint that made the first version wrong. Not a changelog
entry, not a restatement of the diff.
