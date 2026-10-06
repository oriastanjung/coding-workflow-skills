# Workflow

One stacked PR per **vertical slice**. Not one per file, and not one branch for
a whole phase. Work the stack slice by slice, one PR at a time, until every
gate has passed for every slice.

## Loop per slice

1. `gh stack sync`, then `gh stack add <slice-branch>` (Main Agent).
2. Open the slice's PR as a draft before any code (`create-pr.md`). Set the
   slice's ticket to In Progress with the PR link
   (`write-or-update-ticket.md`).
3. Spawn an implementer subagent to build the slice. Commit its paths,
   `gh stack submit`, and post a progress comment on the PR.
4. Review round: spawn a **new** reviewer subagent (`pr-review.md`). It posts
   its report as a PR comment. Main Agent replies on the PR to every
   objection, sends accepted fixes to the implementer, commits, submits, and
   starts the next round. Repeat until the verdict is APPROVE.
5. Spawn a gate subagent to run `lint`, `test`, `build`, `test:e2e`. It posts
   the real output as a PR comment. Red gate: fix, push, new review round.
6. Fill the final PR description, mark the PR ready
   (`gh pr ready <number>`), set the ticket to In Review.
7. Merge, `gh stack sync`, set the ticket to Done with a comment that links
   the PR.
8. Go to the next slice. Stop only when the last slice is merged.

## Division of labour

| Step | Who |
|---|---|
| Implement the slice | implementer subagent |
| Review the diff, post the round on the PR | new reviewer subagent, every round |
| `lint`, `test`, `build`, **`test:e2e`**, post output on the PR | gate subagent |
| Branches, commits, `gh stack`, merge | Main Agent |
| Progress comments and replies to objections on the PR | Main Agent |
| Ticket status | Main Agent |

Main Agent never implements a slice itself. Always use a subagent for
implementation. Delegate first, review second.

## Parallel or sequential

Use the answer from the start question.

- **Sequential**: one subagent at a time, in plan order.
- **Parallel**: independent slices run at the same time. Slices that share a
  file are always serialised. The stack order still follows the plan; commit
  and submit each slice in stack order.

## Running e2e is the gate subagent's job

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

Say it in every brief: `npm run build` is fine for the implementer,
`test:e2e` belongs to the gate subagent alone, one at a time.

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

## Briefing a subagent

Every brief names:

1. The files it may touch, and the files another agent is holding. Two agents
   editing `app.module.ts` will silently drop one edit.
2. The template module to copy — for the backend, `src/modules/loan-request/`
   for a module and `src/lib/face/` for a lib.
3. `AGENTS.md` as required reading, and that it wins over the brief.
4. The gate to run, and that the real output is pasted back, not summarised.
5. **Run no git commands at all** — no commit, push, `checkout`, `pull` or
   `branch`. Main Agent reviews the working diff.
6. The PR number. Reviewer and gate subagents post their report there with
   `gh pr comment`; that is the only write they may do.

## Parallel agents share ONE working tree

All subagents work in the same checkout, branch and index. A `git checkout`
from one agent moves the branch under every other agent; a `git pull`
rewrites files they are editing. That is lost work, not a merge conflict.

Keep one PR per slice anyway: let changes accumulate in the shared tree, then
commit **by path** — `git add <this slice's paths>`. Check
`git status --porcelain` before each commit so nothing from another slice is
staged.

When two agents both add a table, their migration files must not collide. Tell
each to create only its own tables and to hand-write the migration if a
generated diff shows another agent's.

### Never `mv` a live agent's directory to isolate a build

Moving another slice's directory aside to build one slice alone deletes work
from agents still writing. Isolate by **editing `app.module.ts` only**: save a
copy, remove the other slices' registration lines, build, restore from the
copy. Agents re-register their module when they see it missing, so the file
drifts; never restore it with a blind `git checkout`.

If `mv` fails with `Directory not empty`, an agent rewrote the directory while
you held it. Run `diff -rq` on both before deleting either.

## Fix iterations

Every fixing iteration gets one code comment that explains the *why* of the
fix: the hidden constraint that made the first version wrong. Not a changelog
entry, not a restatement of the diff.
