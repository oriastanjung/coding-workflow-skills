# Slice plan

The plan is the contract for the whole stack. Write it in the shape below, in
your agent's plan mode if it has one. Once the user approves it, it lives at
`$WORK/plan.md`. From then on, only that copy changes: the plan reviewer reads
it, the build adds to it, and each slice is checked against it.

A reviewer must be able to read the full plan in one sitting. Drop a section
only when it is truly empty.

```markdown
# <What this work delivers, in one line>

## The ask
Quote the user. Under the quote, state how you read it. When the user picked
one of two readings, say which.

## What the code says
Facts from exploration. Cite file:line for each.
- Earlier or parallel work (PRs, issues, open and closed):
- Current behaviour, entry point to effect:
- Parts to reuse as they are:
- House conventions:
- Real commands: lint `…` · typecheck `…` · build `…` · test `…` · e2e `…` · start `…`

## Design
A few sentences on the chosen design. One more on the obvious alternative
and why it lost.

## Not in this work
Things a reader may expect here, left out on purpose.

## Slices
Stack order, bottom first. Each slice works end to end alone.

### 1 · <slice name> · branch `<branch>`
Touches: <files>

Steps (each small enough to finish and check on its own):
1.

Proof by tests:
| Level | Fails when | File |
|---|---|---|
| Unit | | |
| Integration | | |
| End-to-end | | |
(No tests at a level? Write "n/a" and why.)

Done when (each item is a command and its expected output, or something a
person can watch happen):
- [ ] 1.1
- [ ] 1.2

Proof to capture: <screenshots, recording or terminal output, mapped to the
"done when" items>

### 2 · <slice name> · branch `<branch>`
…

## Unknowns
Risks, and every assumption you did not verify.

## Plan review answers
Written after the plan review. One line per point raised: taken, and what
changed; or declined, and the evidence why.

## Changes during build
Written while building. Slice, what moved away from this plan, and why.
```

## Questions to ask of every design choice

Answer each before the plan goes to the user:

1. **Does the request ask for it?** If no one asked for an option, a layer or
   a hook for later, it does not go in. Error handling, input checks at
   boundaries, tests and security always go in; they are part of doing the
   asked thing right.
2. **Does it exist already?** Look, in this order, and stop at the first hit:
   this repo, the language's standard library, the framework or platform, a
   package already installed, a new package, code you write. A new package
   must remove real complexity to earn its place.
3. **Where does this knowledge live?** Each rule, format or constant gets one
   home. But two pieces of code that only look alike, and change for different
   reasons, stay apart.
4. **Can each module be described without "and"?** If not, it does two jobs.
   Modules talk through their public surface only, dependencies point one way,
   and I/O stays at the edges so the core can be tested without mocks.
5. **Is the stack already solving this?** Let the database filter and join,
   the router route, the type system hold invariants. Check the docs of the
   installed version, not memory.
6. **Does the repo already have a pattern for it?** Follow it, even when you
   prefer another. A better pattern is its own PR.

Put each trade-off you made under Design, so the plan reviewer sees it was a
choice and not an accident.
