# AI agents

The repository is regularly changed with agents (Claude Code, Codex). Their setup is versioned.

## Files

| File | Role |
|---|---|
| `AGENTS.md` | Instructions shared by every agent: repository map, where things go, checks, forbidden commands, PR workflow, temporary-fix registry (in French) |
| `CLAUDE.md` | Imports `AGENTS.md` (`@AGENTS.md`) for Claude Code |
| `.claude/settings.json` | Claude Code project permissions and hooks |
| `.claude/skills/temp-fixes/` | "add / review / resolve a temporary fix" procedure |
| `scripts/hooks/` | Hook scripts |

## Permissions (`.claude/settings.json`)

- **Allowed without confirmation**: targeted evaluation (`nix eval`, `nix flake check --no-build`,
  `nix build --dry-run`), `nix fmt`, `temp-fixes`, `nix-diff`, `statix`, `deadnix`, read-only git.
- **Denied**: `nixos-rebuild switch|boot`, `nh os switch|boot`, `sudo`, garbage collection,
  `git push --force`. You rebuild and activate the system yourself.

Personal settings go to `.claude/settings.local.json` (ignored by git).

## Hooks

| Hook | Script | Effect |
|---|---|---|
| `SessionStart` | `scripts/hooks/temp-fixes-session.sh` | puts the overdue temporary fixes into the agent's context; it must challenge you about them |
| `PostToolUse` (Edit/Write) | `scripts/hooks/format-file.sh` | formats the edited `.nix`, `.sh` or `.lua` file with `nix fmt` |

## Expected verification by an agent

1. Read the code and the diff.
2. `nix fmt`, `temp-fixes lint`.
3. `drvPath` of the affected host: identical for a pure refactor, otherwise `nix-diff` and an
   explanation.
4. `nix flake check --no-build`.
5. Branch + PR: CI replays everything.

## Codex

Codex reads `AGENTS.md` but has no hooks: `AGENTS.md` asks it to run
`nix run .#temp-fixes -- due` at the start of a session.
