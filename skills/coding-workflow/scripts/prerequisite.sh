#!/usr/bin/env bash
set -euo pipefail

GH_ATTACH_MIN_VERSION="2.99.0"

needs_ui_tools=false
[ "${1:-}" = "--ui" ] && needs_ui_tools=true

stop_with() {
  echo "FAIL: $1" >&2
  echo "FIX:  $2" >&2
  exit 1
}

is_older_than() {
  [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort --version-sort | head -n 1)" = "$1" ]
}

command -v gh >/dev/null 2>&1 \
  || stop_with "GitHub CLI (gh) is not installed." "Install it: https://cli.github.com"

gh auth status >/dev/null 2>&1 \
  || stop_with "gh is not logged in." "Run: gh auth login"

gh extension list | grep -q "gh-stack" \
  || stop_with "gh stack extension is not installed." "Run: gh extension install github/gh-stack"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || stop_with "Current directory is not a git repository." "cd into the project repository."

if [ "$needs_ui_tools" = false ]; then
  echo "OK: gh installed, logged in, gh stack available, inside a git repository."
  exit 0
fi

gh_version="$(gh --version | sed -n 's/^gh version \([0-9.]*\).*/\1/p')"
! is_older_than "$gh_version" "$GH_ATTACH_MIN_VERSION" \
  || stop_with "gh $gh_version has no --attach for stills and recordings (from $GH_ATTACH_MIN_VERSION)." "Upgrade gh: https://cli.github.com"

command -v node >/dev/null 2>&1 \
  || stop_with "Node.js is missing; Playwright runs on it." "Install it: https://nodejs.org"

npx --no-install playwright --version >/dev/null 2>&1 \
  || stop_with "Playwright is not available to this project." "Run: npm install --save-dev playwright && npx playwright install"

command -v ffmpeg >/dev/null 2>&1 \
  || stop_with "ffmpeg is missing; it boxes saved images and makes GIFs." "Install ffmpeg with your system package manager."

echo "OK: gh $gh_version with --attach, gh stack, Node.js, Playwright, ffmpeg, inside a git repository."
