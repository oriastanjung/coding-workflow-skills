# Interrogating

Question the user without letting up until you both understand the plan the
same way. Use this while the plan is being written in plan mode, before it is
approved.

## The design tree

Treat the plan as a **design tree**: each decision opens the decisions that
depend on it.

The **frontier** is every decision whose prerequisites are already decided:
the questions you can ask now without guessing at answers you do not have yet.

## Rounds

Ask the full frontier in one round. Number each question and give your
recommended answer. Then wait for the user's answers before the next round.

Use this format:

```
**Q1 - <question title>**: <question body, one or more paragraphs, with choices if there are any>

**Recommended:** <your recommended answer>

---

**Q2 - <question title>**: <question body, one or more paragraphs, with choices if there are any>

**Recommended:** <your recommended answer>
```

Each set of answers changes the tree: decided branches move the frontier out
and unblock the questions that depended on them. Compute the new frontier and
ask the next round. If a question depends on another question that is still
open in the same round, move it to a later round.

## Facts are yours, decisions are the user's

Never ask the user for a fact you can find yourself. When a frontier question
needs a fact from the environment (files, tools, config), send a subagent to
find it. Do not wait for it: only the questions that depend on that fact wait;
ask the rest of the frontier now.

Every decision goes to the user. Ask it and wait for the answer.

## Done

Interrogating is done when the frontier is empty: every branch of the tree visited,
nothing assumed without asking. Do not act on the result until the user
confirms that you share the same understanding. Then write the result into the
plan.
