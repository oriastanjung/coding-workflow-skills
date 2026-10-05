# PR review

After each slice is implemented, spawn a **new** reviewer subagent. Its job
is to find what is wrong. Agreement has no value; a missed problem costs much
more to fix after merge.

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

Read the plan, the diff, and the code around it. Check every claim against the
repository; do not trust it. You are read-only: change nothing, run no git
command that writes.

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

Keep the report as received. Then, for each objection:

- **Accept**: send the fix to the implementing subagent. Record what changed.
- **Reject**: write the reason. "The reviewer misread X, see file:line" is a
  reason. "I disagree" is not.

Verdict actions:

- **APPROVE**: go to the gate and then the PR.
- **APPROVE WITH CHANGES**: fix the accepted objections, then spawn a new
  reviewer on the new diff.
- **REWORK**: go back to the plan for this slice, update it, implement again,
  and review again.

If an objection depends on something only the user can decide, ask the user
before you continue. Put the verdict and the accepted changes in the PR's Plan
check section.
