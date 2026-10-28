---
name: coding-workflow
description: How the owner ships features — read the code, write the plan with references/slice-plan.md and get it approved (no plan, no start), attack the plan yourself, open a GitHub issue per slice, then one stacked PR per vertical slice via `gh stack`, opened as a draft before any code. The issue holds the status; the PR holds progress, every review round and every log. A Haiku subagent per slice only writes code and tests from your brief; the main agent does all git, PR, review, merge and proof work. The main agent reviews every round and posts it on the PR, runs lint, typecheck, test, build and e2e, checks the slice against the plan, uses the app in a real browser and uploads stills with a red box on the change, then merges and closes the issue. Works with any coding agent. Use for any implementation task larger than a one-line fix. Stress-test the plan with references/interrogating.md.
---

# Coding workflow

## Hard gate: a plan must exist

This skill starts only from a plan the user approved. If no plan exists,
stop, write one with the user, and get it approved. Do not implement anything
without it, whatever the request says.

- Your agent has a plan mode? Write the plan there.
- No plan mode? Write the plan to `$WORK/plan.md` (see Scratch space), show
  it, and change no other file until the user says it is approved.

You write the plan yourself. Every planning decision stays with you and the
user.

### Read the code before the plan

Designing before reading is how you rebuild what already exists. Answer these
first:

- **Is someone on it already?** Search PRs and issues, open and closed:
  `gh pr list --state all --search "<terms>"` and
  `gh issue list --state all --search "<terms>"`. A match stops the work
  until the user decides.
- **How does it work now?** Follow the path from entry point to effect.
- **What can be reused?** Helpers, components, services, types, fixtures,
  test tools.
- **What are the house rules?** Conventions, plus the real commands for lint,
  typecheck, build, test, e2e and start, read from the manifest or CI.
- **What do the docs say?** The current docs of each library you touch, for
  the installed version.

Found a false premise in the request, or a much cheaper route? Tell the user
before you plan.

### Write the plan

Use the shape in `references/slice-plan.md`. A junior engineer must be able
to build from it without asking anything: slices in stack order, files per
slice, "done when" items per slice, and the tests and proof for each item.

While you write it, interrogate the user with `references/interrogating.md`
until no decision is left open. Use no other skill for this.

## Pipeline

Run the stages in order. Each stage has its own guide in `references/`.

| # | Stage | Guide |
|---|---|---|
| 0 | Read the code, then plan, interrogate and approve | this file, `references/slice-plan.md`, `references/interrogating.md` |
| 1 | Run `scripts/prerequisite.sh` | this file |
| 2 | Ask the start question | this file |
| 3 | Main agent attacks its own plan against `plan-challenge.md`'s prompt | `references/plan-challenge.md` |
| 4 | Write or update the issue | `references/write-or-update-ticket.md` |
| 5 | Open the slice's stacked PR as a draft | `references/create-pr.md` |
| 6 | Build, review rounds on the PR, gate on the PR | `references/workflow.md`, `references/test-levels.md`, `references/pr-review.md` |
| 7 | Prove: against the plan, as a user, with red-boxed stills | `references/workflow.md`, `references/proof-capture.md` |
| 8 | Mark ready, merge, close the issue, next slice | `references/workflow.md`, `references/create-pr.md` |

## Who does what

Two roles. Neither crosses into the other's work.

**Main agent (you, the one the user talks to)** owns everything except
writing code:

- plan, interrogation, approval
- every git and GitHub action: branch, commit, push, issue, PR, comments,
  ready, merge, issue close
- review of every round (you read the diff yourself; no outside reviewer)
- gate runs you rely on, the plan check, browser proof and red-boxed stills
- progress reports to the user

**Implementor subagent** writes code and nothing else:

- Model: **Haiku**, always. Check once per session that the alias really
  resolves to Haiku (one-line probe) before the first slice.
- One subagent per slice, run one at a time, never in parallel on one repo.
- It edits files, writes tests, and runs the lint, typecheck, test and build
  commands you name, then reports its diff summary and raw gate output.
- It does **not** run git (no branch, commit, push, stash), `gh`, `gh stack`,
  PR or issue commands; it does not merge, capture proof, review, spawn
  agents, or touch files outside its brief.
- Its brief, written by you, holds: repo path, house rules file, the slice
  section of the plan, exact files, exact commands, and what to report.

After it reports, you read its diff, re-run the gate yourself, fix the brief
and send it back if anything is off, then do the git, PR and proof steps.
Before every merge, confirm the PR base is the repo's integration branch
(`gh pr view <n> --json baseRefName`), never a GitHub default you did not
choose.

## Ticket for status, PR for progress

- The **ticket** is a GitHub issue. It holds the status only: In Progress,
  In Review, Blocked, Done.
- The **PR** holds the rest: each build step, each review round, each reply
  to a fault, each gate run, the plan check and the proof. If it happened, it
  is a comment on the PR. Nothing lives only in the chat.

Repeat stages 5 to 8 slice by slice, one stacked PR at a time, until every
slice has passed every stage. Do not stop at a partial stack.

## House rules beat this skill

While reading the code, also read how the repo wants work done: `AGENTS.md`,
`CLAUDE.md`, `CONTRIBUTING.md`, its PR template, branch names, commit style.
If any of them clash with this skill, the repo wins. This skill sets the order
of work and how much proof is enough; the repo sets its own conventions.

## Scratch space

The plan copy, the plan review and raw proof must never reach a commit. Keep
them under `.git`, where git does not look:

```bash
WORK="$(git rev-parse --absolute-git-dir)/coding-workflow"
mkdir -p "$WORK"
```

Every worktree has its own git dir, so each gets its own scratch space.

## Stage 1: prerequisites

```bash
bash <this skill's folder>/scripts/prerequisite.sh
```

Plan touches a screen? Add `--ui`. Then it also demands what the stills need:
`gh` 2.99.0+, node, Playwright and ffmpeg.

On failure, show the user the output and the fix it prints. Anything that
installs software on their machine waits for their yes. Go on only once it
passes.

## Stage 2: ask before starting

Ask the user before any work (use your agent's question tool if it has
one): **Does this work already have a GitHub issue in this repo?** If yes, get the issue number. Tickets are always
GitHub issues (`references/write-or-update-ticket.md`).

## No "done" before the last merge

The words done, finished and ready wait for the last merged slice. Until then
give the position: "Slice 2 of 4: review round 3, gate not run yet."

A stage that has nothing to act on (no screen, so no browser) passes when the
PR states that and why. A stage that should run but cannot is a blocker:

1. Push on it first: setup docs, a documented workaround, one retry for a
   flaky failure.
2. Still stuck? Finish every stage that can still run. The PR stays a draft
   and opens with a "Not verified" line: what is missing, and why. The issue
   gets `status: blocked`.
3. Tell the user which stage is stuck and the exact step that frees it.

Never fake a stage. Output is real or absent, stills come only from the
final code, and a claim of green tests needs a run to back it.

## Stay on target

If your agent can hold a standing goal (for example `/goal` in Claude Code),
set it to the plan's objective so the run stays on track until every slice is
in. The goal is reached only when the last stacked PR is merged and its issue
is closed.
