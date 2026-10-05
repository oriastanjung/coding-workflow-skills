#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "FAIL: $1" >&2
  echo "FIX:  $2" >&2
  exit 1
}

command -v gh >/dev/null 2>&1 \
  || fail "GitHub CLI (gh) is not installed." "Install it: https://cli.github.com"

gh auth status >/dev/null 2>&1 \
  || fail "gh is not logged in." "Run: gh auth login"

gh extension list | grep -q "gh-stack" \
  || fail "gh stack extension is not installed." "Run: gh extension install github/gh-stack"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail "Current directory is not a git repository." "cd into the project repository."

echo "OK: gh installed, logged in, gh stack available, inside a git repository."
