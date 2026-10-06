# PR review

Every review round spawns a **new** reviewer subagent. Its job is to find what
is wrong. Agreement has no value; a missed problem costs much more to fix
after merge.

Every round is posted on the slice's PR as a comment. A round that is not on
the PR did not happen. Each round challenges again: the new reviewer reads the
earlier rounds on the PR and checks that every accepted fix is real and that
every rejection holds up.

## Choosing the reviewer

In order of preference:

1. A new subagent in a fresh context, on the same model or a
   stronger one.
2. A different agent CLI or model in non-interactive mode, pointed at the repo.
3. A new session of the same agent, started with only this brief.
4. Self-review against this brief. This is not independent; say so in the PR.

Never use a weaker model. Weaker reviewers miss design problems and raise
style points instead.

## The brief

Send this prompt with the placeholders filled in. Send nothing else: no
summary of your reasoning, no hint about what you think is good.

```text
You are reviewing one slice of a stacked change. Your job is to find what is
wrong with it. Agreement is not useful; a missed problem costs much more to fix
after merge.

Repository: <absolute path>
Plan: <absolute path to the plan>
Slice: <slice name and its acceptance criteria>
Diff: <how to get it, e.g. `git diff <base-branch>...HEAD` or the uncommitted paths>
Original request: <the user's request, word for word>
PR: <number>
Round: <N>

Read the plan, the diff, the code around it, and the earlier review rounds on
the PR (`gh pr view <number> --comments`). Check every claim against the
repository; do not trust it. Challenge the earlier rounds: is each accepted
fix really done, and does each rejection hold up? You are read-only: change
nothing, run no git command that writes. Your only write is the report, posted
with `gh pr comment <number> --body-file <file>`, titled "Review round <N>".

Look for:
1. Wrong premises. Does the change misread the request or the existing code?
2. Missed reuse. Does the codebase, the standard library or an installed
   dependency already do what the diff writes by hand?
3. Over-building. Anything the request does not need: options, layers,
   abstractions, speculative cases.
4. Under-building. Failure modes, edge cases, concurrency, permissions,
   migrations, backwards compatibility, or callers the change does not handle.
5. Coupling and cohesion. Code in the wrong place, or modules that depend on
   each other's internals.
6. Tests. Would each test fail if the feature were broken? Is a level (unit,
   integration, end-to-end) missing or wrongly marked not applicable?
7. Acceptance criteria. Is each one met and observable? Could all of them pass
   while the request is still not met?
8. Security. Secrets, injection, missing authorization, unsafe defaults.
9. A simpler route. Is there a much cheaper way to meet the request?

Report format:
- Verdict: one of APPROVE, APPROVE WITH CHANGES, REWORK.
- Objections, most serious first. For each: what is wrong, the evidence
  (file:line or plan section), and what to do instead.
- Claims you checked and found correct, briefly.
- What you could not verify.

Raise only objections you can support with evidence from the repo or the
request. Do not add style preferences to fill the list.
```

## Handling the report

The report stays on the PR as posted. Then Main Agent posts one reply comment
on the PR that answers every objection:

- **Accept**: send the fix to the implementing subagent. Name the commit that
  fixes it.
- **Reject**: write the reason. "The reviewer misread X, see file:line" is a
  reason. "I disagree" is not.

Verdict actions:

- **APPROVE**: go to the gate.
- **APPROVE WITH CHANGES**: fix the accepted objections, push, then start the
  next round with a new reviewer.
- **REWORK**: go back to the plan for this slice, update it, implement again,
  and review again.

If an objection depends on something only the user can decide, ask the user
before you continue, and post the answer on the PR. Put the round count and
the final verdict in the PR's Plan check section.
