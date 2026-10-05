# coding-workflow

A Claude Code skill for shipping features as a stack of small, reviewed pull
requests.

The skill makes the agent plan first, track the work in a ticket, and deliver
one vertical slice per stacked PR with [`gh stack`](https://github.com/github/gh-stack).
Subagents do the implementation. A new reviewer subagent checks every slice,
and every slice must pass lint, test, build and end-to-end tests before merge.

## Credits

Co-authored by **RealtaNua** ([Nael-Nathanael](https://github.com/Nael-Nathanael)).

Parts of this skill are adapted from the
[ship-pr](https://github.com/Nael-Nathanael/ship-pr/tree/main) skill (MIT):

| This skill | Adapted from |
|---|---|
| PR description template in `references/create-pr.md` | [PR template](https://github.com/Nael-Nathanael/ship-pr/blob/main/skills/ship-pr/references/pr-template.md) |
| Reviewer brief in `references/pr-review.md` | [Challenge brief](https://github.com/Nael-Nathanael/ship-pr/blob/main/skills/ship-pr/references/challenge-brief.md) |

## How it works

| # | Stage | Guide |
|---|---|---|
| 0 | An approved plan exists, settled by interrogating the user | `references/interrogating.md` |
| 1 | Prerequisite check | `scripts/prerequisite.sh` |
| 2 | Start questions: parallel or sequential subagents, and existing tickets | `SKILL.md` |
| 3 | Write or update the ticket | `references/write-or-update-ticket.md` |
| 4 | Implement the slice, then review it | `references/workflow.md`, `references/pr-review.md` |
| 5 | Open the stacked PR | `references/create-pr.md` |
| 6 | Merge, update the ticket, go to the next slice | `references/workflow.md` |

Stages 4 to 6 repeat slice by slice until the last PR is merged.

Rules the skill enforces:

- **No plan, no start.** The skill stops if there is no approved plan from
  plan mode.
- **Parallel or sequential.** The agent asks first. Sequential suits the $20
  plan; parallel suits Max and Max $200.
- **Tickets first.** It uses a connected ticketing MCP server (Linear, Jira,
  Trello, Slack, Obsidian, Plane, or other). If none is connected, it uses
  GitHub Issues.
- **Always `gh stack`.** One vertical slice per branch and PR. The stack is
  kept in sync after every change.
- **Independent review.** A new reviewer subagent, in a fresh context, reviews
  every slice. Main Agent never implements a slice itself.
- **One e2e run at a time.** Concurrent runs against a shared database corrupt
  each other's fixtures.

## Requirements

- [Claude Code](https://claude.com/claude-code)
- [GitHub CLI](https://cli.github.com), logged in (`gh auth login`)
- The `gh stack` extension:

  ```bash
  gh extension install github/gh-stack
  ```

- Optional: a ticketing MCP server. Without one, GitHub Issues is used.

## Install

Install with the [skills.sh](https://skills.sh) CLI:

```bash
npx skills add oriastanjung/coding-workflow-skills
```

Check the prerequisites:

```bash
bash ~/.claude/skills/coding-workflow/scripts/prerequisite.sh
```

## Usage

1. Enter plan mode and describe the feature. Answer the interrogation rounds
   until every decision is settled, then approve the plan.
2. Start the run with `/goal <the plan's objective>` so the session stays on
   target until the last slice is merged.
3. Invoke `/coding-workflow`, or ask for the feature and let the skill trigger.
4. Answer the two start questions. The agent then works the stack slice by
   slice.

## Layout

```
skills/coding-workflow/
├── SKILL.md
├── scripts/
│   └── prerequisite.sh
└── references/
    ├── interrogating.md
    ├── write-or-update-ticket.md
    ├── workflow.md
    ├── pr-review.md
    └── create-pr.md
```

## License

[MIT](LICENSE.md)
