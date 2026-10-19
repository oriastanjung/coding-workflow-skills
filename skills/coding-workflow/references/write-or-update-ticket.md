# Write or update the ticket

Every slice in the plan has one ticket. The ticket is always a GitHub issue in
the current repository, made with `gh issue`. Do not use any other ticketing
tool, even when one is connected.

The ticket records what the slice must do and its status. Progress, review
rounds and logs go on the slice's PR, not on the issue.

## 1. Find before you create

Search the repo's issues for one that covers the slice: by the issue number
the user gave, then by title keywords.

```bash
gh issue view <number>
gh issue list --state all --search "<keywords>"
```

- **Issue exists**: update it. Set the status label to match the work, and
  add a comment that links the plan and names the slice.
- **No issue**: create one per slice.

## 2. What a new issue contains

- Title: one line on what the user or the system gains.
- Body: the why, the slice scope, and the files it touches.
- The slice's "done when" items, copied from the plan, as a checklist. Each
  one must be observable and checkable.
- A link to the parent issue when the plan has one.

```bash
gh issue create --title "<title>" --body-file <body.md>
```

## 3. Keep the status true

GitHub issues have no status field, so the status is a label. Create the
labels once per repo; `--force` makes this safe to run again:

```bash
gh label create "status: in progress" --color FBCA04 --force
gh label create "status: in review" --color 0E8A16 --force
gh label create "status: blocked" --color B60205 --force
```

Change the status with one label at a time:

```bash
gh issue edit <number> --remove-label "<old status>" --add-label "<new status>"
gh issue comment <number> --body "<comment>"
```

| Moment | Status | Comment |
|---|---|---|
| Slice starts, draft PR opened | label `status: in progress` | Plan link, slice name, PR link |
| PR marked ready | label `status: in review` | PR link |
| PR merged, gate green | `gh issue close <number> --comment "<PR link>"`, remove the status label | PR link |
| Gate blocked | label `status: blocked` | Link to the PR comment that says what is missing |

A stacked PR targets the branch below it, not the default branch, so
`Closes #<number>` in its body does not close the issue. Close it yourself.

Never close an issue while any gate is red.
