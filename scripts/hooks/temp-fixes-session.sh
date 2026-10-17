#!/usr/bin/env bash
# Claude Code SessionStart hook: put the temporary fixes whose review date has
# passed into the agent's context, so it can challenge the user about them
# (see AGENTS.md, "Registre des fix temporaires").
set -u

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0

if command -v temp-fixes >/dev/null 2>&1; then
  due="$(temp-fixes due --format brief 2>/dev/null)"
else
  due="$(nix run .#temp-fixes -- due --format brief 2>/dev/null)"
fi

[ -n "$due" ] || exit 0

cat <<MSG
Fix temporaires dont la date de revue est passée (temp-fixes.toml) :
$due

Consigne (AGENTS.md) : en début de réponse, challenge l'utilisateur sur au plus deux
de ces fix (toujours nécessaire ? test proposé), puis consigne sa décision dans
temp-fixes.toml (last_challenged, history, nouveau review_after ou résolution).
MSG
