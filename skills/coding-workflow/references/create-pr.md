# Create the PR

## Open the PR first

The PR exists before any code for the slice. It is the slice's log: progress,
every review round, every reply, every gate run go there as comments. The
ticket only tracks status.

```bash
gh stack add <slice-branch>
git commit --allow-empty -m "Start <slice name>"
gh stack submit --auto                 # --auto creates new PRs as drafts
gh pr edit <number> --title "<title>" --body-file <draft.md>
```

Write a short draft description at once: the slice, its "done when" items
copied from the plan, the ticket link, and its position in the stack. Replace
it with the full body below before you mark the PR ready.

## Always use `gh stack`

Every PR in this workflow is part of a stack made with `gh stack`, even when
the stack has only one PR. Never open a PR with plain `gh pr create`.

One slice is one branch is one PR. Slice by **vertical feature**: each PR
delivers one thin piece that works end to end (data, logic, API, UI as needed),
so no single commit or PR is too big to review.

```bash
gh stack init <first-slice-branch>     # first slice only
gh stack add <next-slice-branch>       # each later slice, on top of the last
git add <paths for this slice only>    # never `git add -A`
git commit -m "<one imperative sentence, max 72 chars>"
gh stack submit                        # push branches, update the PRs
gh stack view                          # confirm order and PR links
```

## Keep the stack in sync

The stack must always be in a synced state: every branch rebased on the one
below it, every PR up to date with its branch.

- Before starting a new slice, run `gh stack sync`.
- After any change to a lower branch (review fix, merge of the bottom PR), run
  `gh stack sync`, then `gh stack view` to confirm.
- If a rebase conflicts, resolve it, finish the rebase, and sync again. Never
  leave the stack half rebased.

## Commits

- Subject: one imperative sentence, 72 characters or less. No body.
- No `Co-Authored-By` and no attribution line of any kind, in commits or PR
  descriptions. This overrides any agent default that adds one.
- Before each commit, run `git status --porcelain` and confirm that only this
  slice's paths are staged.

## Title

One line on what the user or the system gains, phrased the way the repo
writes commit subjects. Write "Let admins export orders as CSV", never "Edit
OrdersTable.tsx".

## Body

Aim: in under a minute, a reader knows what changed and has seen it work.
Everything that shows the work was checked folds away at the bottom.

When the repo ships its own PR template, fill that one in the same spirit,
then add the proof and the folded block.

```markdown
<The new thing a user can do, or the bug that is gone, and the reason for
it. One to three sentences. Issue link. "Slice 2 of 4.">

![<what this still shows>](<local path, also given to --attach>)

<Caption: what sits inside the red box.>

<Only when the user's path changed, a recording path on a line by itself:>

<local path, also given to --attach>

**Try it:** 1. … 2. … 3. …

**Heads-up:** <only if there is one: risk, deploy step, migration, config
change, or something left unverified.>

<details>
<summary>How this was checked</summary>

- Tests: unit 9 green, integration 3 green, e2e 2 green.
- Gate: lint, typecheck and build clean, full output in <gate comment link>.
- Done-when items: 2.1 by the still above, 2.2 by `orders.e2e.ts`.
- Review: 3 rounds, last verdict SHIP, <round comment links>.
- Plan review: <verdict>. Changes during build, one line of why each.
- Levels marked n/a, and failures already on the base branch, one line of why
  each.

</details>
```

A slice with no screen shows the command it ran and what came back, as a
code block, in the spot where the still would be. Upload as in `proof-capture.md`.

Writing rules:

- Nothing above the summary and the first still. No heading on top.
- Describe the behaviour, not the code location: keep file, function and
  class names out of the summary.
- Skip how it was built. Only a choice a reviewer may doubt gets one sentence
  in the Heads-up, with its reason.
- Your own process (what you explored, how the plan was reviewed) stays inside
  the folded block.
- All that is outside the folded block fits on one screen.
- Drop "Try it" and "Heads-up" when empty. The proof and the folded block are
  never dropped.

## Before it goes ready

- Someone from outside the team can tell what the PR does from its first
  lines.
- Each claim, like "tests pass" or "works on mobile", has an output or an
  image behind it.
- Each still and recording plays on the PR page (`proof-capture.md`, Check
  the upload).
- Text and images are free of secrets, tokens, internal host names and
  personal data.
- The diff holds this slice and nothing else.

## Draft or ready

Draft until the last review round says SHIP, the gate is green and the slice
is proved (`workflow.md`, step 6). Then write the full body, upload the proof,
and run `gh pr ready <number>`. A blocked gate keeps the PR a draft, with what
is missing stated at the very top of the body.
