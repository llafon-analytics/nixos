#!/usr/bin/env bash
# Claude Code PostToolUse hook: format the file that was just edited with the
# repository formatter (treefmt: nixfmt, shfmt, stylua...). Never blocks the agent.
set -u

file="$(jq -r '.tool_input.file_path // empty' 2>/dev/null)"
case "$file" in
*.nix | *.sh | *.lua) ;;
*) exit 0 ;;
esac
[ -f "$file" ] || exit 0

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0
nix fmt -- "$file" >/dev/null 2>&1 || true
exit 0
