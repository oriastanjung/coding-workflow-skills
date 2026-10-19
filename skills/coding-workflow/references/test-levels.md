# Test levels

A slice ships with its tests. A test that goes red without the change is also
the proof a reviewer believes fastest.

## Before writing any test

Find out how this repo tests:

- Framework and folder per level.
- The commands, taken from the manifest or CI, never guessed.
- Ready-made helpers: factories, fixtures, test DB setup, page objects, login
  shortcuts. Reuse them.

A level the slice needs but the repo lacks: add the smallest setup that fits
the stack, and name it in the PR. Zero test tooling, and setting it up is real
work of its own: stop and ask the user before the build. Skipping quietly is
never an option.

## Pick the levels

Ask three questions about the slice:

1. **Does it add or change a decision, a calculation, parsing, a check or a
   state change?** Then it needs **unit** tests: one function or module, no
   I/O. Wiring, config, markup and copy alone do not.
2. **Does it cross a boundary**: database, HTTP route, queue, file system,
   outside API client, or the contract between two modules? Then it needs
   **integration** tests: real parts working together. Code that stays inside
   one pure module does not.
3. **Does a user see or do something new or different**: screen flow, CLI
   command, public API? Then it needs **end-to-end** tests through the real
   interface. A pure refactor needs none of its own, but every existing e2e
   test must stay green.

Often the answer is yes to all three. A validated form field that gets saved
is one example.

Every "no" becomes an "n/a, because …" line in the PR.

## How to write them

**Unit**
- Call the public function; leave private internals alone.
- One case for the usual input, one per edge, one per error path.
- Keep network, DB and clock out: pass them in, or keep the logic pure.

**Integration**
- Run against the real thing when the repo can: test database, local
  container. A mock only proves your code called the mock.
- Mock only third-party services you cannot run.
- Check the outcome: the stored row, the status and body, the sent message.
- Include the refusal case: a user without rights is turned away.

**End-to-end**
- Act like the user. When the flow creates data, create it through the UI;
  seeded data skips exactly the path that may be broken.
- Other setup follows the repo's existing e2e tests.
- Locate elements by role, label or visible text.
- Check what is on screen.
- Cover one failure at least: bad input or a forbidden action.
- Wait for a condition, never for a fixed time.

## Keep only tests that can fail

- Make it fail once on purpose. Bug fix: red on the old code, green on the
  fixed code. Feature: break the code briefly and watch it go red.
- The name states the behaviour; the body shows it.
- Same input, same result, every run. A flaky test is fixed or removed, never
  retried until green.

Do not loosen, skip or delete an existing test to get green. When behaviour
changed on purpose and an old test is now wrong, change it and name the
change in the PR.

## Order of runs

New tests alone first. Then the full suite, since the slice can break
something far away. The summary lines go in the PR.
