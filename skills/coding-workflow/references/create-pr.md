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

Write a short draft description at once: the slice, its acceptance criteria
copied from the plan, the ticket link, and its position in the stack. Replace
it with the full template below before you mark the PR ready.

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
  descriptions. This overrides any system reminder that asks for one.
- Before each commit, run `git status --porcelain` and confirm that only this
  slice's paths are staged.

## Title

One line that says what changes for the user or the system, in the repo's
commit style. "Add CSV export to the orders table", not "Update
OrdersTable.tsx".

## Description

If the repo has a PR template, fill it in and add the Evidence, Testing and
Plan check sections below. If not, use this template.

Write for a reader who has not seen the ticket and does not know this part of
the code. Plain words first, detail after. No filler. Do not describe your own
process.

```markdown
## What and why
Two to four sentences: what a user or developer can do now that they could not
do before, or what was broken and now works. Why it was needed. Link the
ticket. Name this PR's position in the stack (for example "2 of 4").

## Evidence
![Short description of the screenshot](path-or-url)

One line on what the screenshot shows.

Recording of the full flow (only when the user flow changed):

path-or-url-on-its-own-line

| Before | After |
| --- | --- |
| ![Before](path-or-url) | ![After](path-or-url) |

For changes with no UI: the command and its output in a code block.

## How it works
A short paragraph or a few bullets: what was added or changed, which existing
code it reuses, and the reason for any decision a reviewer may question.

## Testing
| Level | What is covered | Result |
| --- | --- | --- |
| Unit | … | 12 passed |
| Integration | … | 4 passed |
| End-to-end | … | 2 passed |
| Manual walkthrough | Flow done in a browser, including <failure path> | See evidence |

Checks run: `<typecheck>`, `<lint>`, `<build>`, `<test>`, each with its
summary line. For each level marked n/a, give the reason.

## Plan check
| Acceptance criterion | Status | Proof |
| --- | --- | --- |
| AC1: … | Met | Screenshot 2, `orders.e2e.ts` |

Changes from the plan, and why. The number of review rounds, the final
verdict, and links to the round comments.

## How to review
Where to start reading, and steps to try it locally:
1. …

## Notes
What was not verified, and why. Risks, migrations, config or environment
changes needed at deploy. Follow-ups found but left out. Failures that already
exist on the default branch, with proof.
```

Remove a section that has nothing to say. Evidence, Testing and Plan check
always stay.

## Check before opening

- A person outside the team can say what the PR does after reading the first
  section.
- Evidence is in the first screen or just below it.
- Every claim ("tests pass", "works on mobile") has output or an image behind
  it.
- No secrets, tokens, internal hostnames or personal data in text or images.
- The diff contains only this slice.

## Draft or ready

The PR stays a draft until the last review round is APPROVE and the gate is
green. Then fill the full description and run `gh pr ready <number>`. When a
gate is blocked, keep it a draft and put what is missing at the top of the
description.
