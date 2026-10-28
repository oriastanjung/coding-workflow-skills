# PR review

Each review round has a **fresh** reviewer that knows nothing of your
reasoning. It is there to find faults. A reviewer who only agrees adds
nothing, and a fault found after merge costs far more than one found now.

Each round lives on the slice's PR as a comment; a round that is not there
did not happen. Rounds build on each other: the new reviewer reads the old
rounds and tests whether each fix you claimed is really in the code and
whether each point you declined was declined for a sound reason.

## Who reviews

The main agent, against the prompt below. Never the Haiku implementor, and
no outside reviewer agent: the implementor is a lower tier and wrote the
code. Read the diff cold, as if someone else wrote it, and say on the PR
that the review was done by the main agent.

## Prompt

Fill in the fields and send this, and only this. Do not explain your choices
or point at the parts you are proud of.

```text
Find what is wrong with one slice of a stacked change. Agreement helps no one;
every fault you miss here reaches production.

Repo: <absolute path>
Plan: <absolute path to $WORK/plan.md>
Slice: <name, and its "done when" items>
Diff: <how to see it, e.g. `git diff <base-branch>...HEAD`>
User's request, verbatim: <request>
PR: <number>
Round: <N>

Read the plan, the diff, the code around the diff, and every earlier round on
the PR (`gh pr view <number> --comments`). Confirm claims in the repo instead
of trusting them. For earlier rounds: is each claimed fix truly in the code?
Does each declined point stay declined for a sound reason?

You may not edit files or run any git command that writes. The one write you
may do is your report: `gh pr comment <number> --body-file <file>`, with the
title "Review round <N>".

Questions to answer:
- Premise: did the change read the request and the existing code right?
- Reuse: does the diff hand-write something the repo, the standard library or
  an installed package already does?
- Excess: options, layers or cases nobody asked for?
- Gaps: errors, edge cases, races, access rights, migrations, old callers,
  backwards compatibility?
- Placement: code in the wrong module, or one module leaning on another's
  internals?
- Tests: would each test go red if the feature broke? Is a level missing, or
  marked n/a without good cause?
- Done-when items: is each met, and can each be seen? Could all pass while the
  request is still unmet?
- Security: leaked secrets, injection, missing access checks, unsafe defaults?
- Cost: is there a far cheaper path to the same result?

Report layout:
Verdict: SHIP | FIX AND RE-REVIEW | REPLAN SLICE
Then each fault, worst first: the fault, where it shows (file:line or plan
heading), and the fix you propose.
Then: claims you confirmed, in short.
Then: what you could not confirm.

Every fault needs evidence from the repo or the request. Leave out taste.
```

## Answering the round

The reviewer's comment stays as posted. You then post one reply on the
PR that covers every fault:

- **Taken**: fix it, and name the commit with the fix.
- **Declined**: give evidence, such as "the reviewer missed the guard at
  file:line". A bare "disagree" is not an answer.

Then act on the verdict:

| Verdict | Next |
|---|---|
| SHIP | Run the gate. |
| FIX AND RE-REVIEW | Fix what you took, push, and open a new round with a new reviewer. |
| REPLAN SLICE | Rewrite this slice in the plan, build it again, review again. |

A fault only the user can settle goes to the user first; post their answer on
the PR. The PR's collapsed proof block lists how many rounds ran and the last
verdict.
