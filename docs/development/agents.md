# Agents IA

Le dépôt est régulièrement modifié avec des agents (Claude Code, Codex). Leur cadre est versionné.

## Fichiers

| Fichier | Rôle |
|---|---|
| `AGENTS.md` | Consignes communes à tous les agents : carte du dépôt, où ajouter quoi, vérifications, interdits, flux PR, registre des fix temporaires |
| `CLAUDE.md` | Importe `AGENTS.md` (`@AGENTS.md`) pour Claude Code |
| `.claude/settings.json` | Permissions et hooks Claude Code du projet |
| `.claude/skills/temp-fixes/` | Procédure « ajouter / revoir / résoudre un fix temporaire » |
| `scripts/hooks/` | Scripts des hooks |

## Permissions (`.claude/settings.json`)

- **Autorisé sans confirmation** : évaluations ciblées (`nix eval`, `nix flake check --no-build`,
  `nix build --dry-run`), `nix fmt`, `temp-fixes`, `nix-diff`, `statix`, `deadnix`, lecture git.
- **Interdit** : `nixos-rebuild switch|boot`, `nh os switch|boot`, `sudo`, garbage collection,
  `git push --force`. C'est vous qui reconstruisez et activez le système.

Les réglages personnels vont dans `.claude/settings.local.json` (ignoré par git).

## Hooks

| Hook | Script | Effet |
|---|---|---|
| `SessionStart` | `scripts/hooks/temp-fixes-session.sh` | injecte les fix temporaires en retard de revue dans le contexte de l'agent, qui doit vous challenger dessus |
| `PostToolUse` (Edit/Write) | `scripts/hooks/format-file.sh` | formate le fichier `.nix`, `.sh` ou `.lua` modifié avec `nix fmt` |

## Vérification attendue d'un agent

1. Lecture du code et du diff.
2. `nix fmt`, `temp-fixes lint`.
3. `drvPath` du host concerné : identique pour un refactor pur, sinon `nix-diff` et explication.
4. `nix flake check --no-build`.
5. Branche + PR : la CI rejoue tout.

## Codex

Codex lit `AGENTS.md` mais n'a pas de hooks : `AGENTS.md` lui demande de lancer
`nix run .#temp-fixes -- due` en début de session.
