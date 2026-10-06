# Write or update the ticket

Every slice in the plan has one ticket. The ticket records what the slice must
do and its status. Progress, review rounds and logs go on the slice's PR, not
on the ticket.

## 1. Pick the tool

1. Ask the user which project the work belongs to. Never guess the project.
2. Use a ticketing MCP server if one is connected in this session: Linear,
   Jira, Trello, Slack, Obsidian, Plane, or any other. If more than one is
   connected, use the one the user named in the start questions.
3. If no ticketing MCP is connected, use GitHub Issues through `gh issue`.

## 2. Find before you create

Search the chosen tool for an existing ticket that covers the slice: by the
ticket id the user gave, then by title keywords.

- **Ticket exists**: update it. Set the status to match the work (for example
  "In Progress" when implementation starts), and add a comment that links the
  plan and names the slice.
- **No ticket**: create one per slice, in the project the user named.

## 3. What a new ticket contains

- Title: what changes for the user or the system, in one line.
- Description: the why, the slice scope, and the files it touches.
- Acceptance criteria, copied from the plan. Each one must be observable and
  checkable.
- A link to the parent ticket or epic when the plan has one.

GitHub Issues fallback:

```bash
gh issue create --title "<title>" --body-file <body.md> --label "<label>"
gh issue comment <number> --body "<status update>"
gh issue close <number> --comment "<PR link>"
```

## 4. Keep the status true

| Moment | Status | Comment |
|---|---|---|
| Slice starts, draft PR opened | In Progress | Plan link, slice name, PR link |
| PR marked ready | In Review | PR link |
| PR merged, gate green | Done | PR link |
| Gate blocked | Blocked | Link to the PR comment that says what is missing |

Never mark a ticket Done while any gate is red.
