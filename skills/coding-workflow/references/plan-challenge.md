# Plan challenge

Whoever wrote the plan is the worst person to find its holes. So before the
first slice is built, an outside reader attacks the approved plan.

**Who reads it.** The main agent, against the prompt below, before any
subagent is briefed. No outside reviewer agent and never the Haiku
implementor. Every PR in the stack says the plan review was done by the main
agent.

**What it gets.** The prompt below, filled in, and nothing more. No account of
how you reached the plan, no word on which parts you trust.

## Prompt

```text
Attack this plan. No code has been written yet. Praise is worthless here;
every flaw you find now is cheap, every flaw you miss gets built.

Repo: <absolute path>
Plan: <absolute path to $WORK/plan.md>
User's request, verbatim: <request>
Write your findings to: <absolute path to $WORK/challenge.md>

Do not edit anything else. Open the files the plan cites and confirm each
claim yourself before you rely on it.

Questions to answer:
- Premise: did the plan read the request and the code right? Test every fact
  under "What the code says" against its file:line.
- Reuse: is the plan writing something the repo, the standard library or an
  installed package already does?
- Excess: does it add options, layers or cases nobody asked for?
- Gaps: what about errors, edge cases, races, access rights, migrations, old
  callers, backwards compatibility?
- Placement: is any code landing in the wrong module, or reaching into
  another module's internals?
- Slicing: can each slice ship and work alone? Is the stack order sound? Is
  any slice too large to review at once?
- Tests: would each planned test go red if the feature broke? Is any level
  missing, or marked n/a without good cause?
- Done-when items: can each be observed? Could every item pass and the user
  still not get what they asked for?
- Cost: is there a far cheaper path to the same result?

Write the findings file like this:
Verdict: BUILD | BUILD AFTER EDITS | REPLAN
Then each problem, worst first: the problem, where it shows (file:line or
plan heading), and the fix you propose.
Then: claims you confirmed, in short.
Then: what you could not confirm.

Every problem needs evidence from the repo or the request. Leave out taste.
```

## After the findings

Leave `challenge.md` as the reviewer wrote it. Answer each problem in the
plan's "Plan review answers":

- **Taken**: edit the plan; note the edit.
- **Declined**: give evidence, such as "the reviewer missed the guard at
  file:line". A bare "disagree" is not an answer.

Then act on the verdict:

| Verdict | Next |
|---|---|
| BUILD | Create the tickets. |
| BUILD AFTER EDITS | Edit the plan, show the user what changed, then create the tickets. |
| REPLAN | Back to planning with the user. Run this challenge again on the new plan. |

A problem that only the user can settle goes to the user before any ticket is
made.
