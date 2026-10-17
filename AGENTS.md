# Consignes pour les agents (Claude Code, Codex…)

Configuration NixOS (flake) de deux machines : **desktop** (NVIDIA, CUDA) et **laptop** (AMD).
Home Manager, Stylix, Hyprland + Caelestia. Parle à l'utilisateur **en français** ; code, commentaires
et messages de commit **en anglais** (Conventional Commits).

## Carte du dépôt

| Chemin | Contenu |
|--------|---------|
| `flake.nix` | Inputs uniquement ; les sorties sont dans `flake/*.nix` (flake-parts) |
| `flake/` | `hosts.nix`, `packages.nix`, `checks.nix`, `devshell.nix`, `treefmt.nix` |
| `lib/mkHost.nix` | Fabrique d'un hôte (`specialArgs` : `inputs`, `pkgs-unstable`) |
| `hosts/<hôte>/` | `default.nix` (système), `hardware.nix`, `home.nix` (Home Manager), `hyprland.lua` |
| `modules/nixos/` | Modules système partagés ; `default.nix` est le point d'entrée commun |
| `modules/home/` | Modules Home Manager ; `common.nix` = tout ce que les deux utilisateurs partagent |
| `pkgs/<nom>/package.nix` | Paquets locaux (`callPackage`) |
| `overlays/` | Overlays (liste dans `overlays/default.nix`) |
| `dotfiles/` | Fichiers de config bruts liés par Home Manager |
| `scripts/` | Scripts shell ; ceux utilisés par Nix sont lus avec `builtins.readFile` |
| `temp-fixes.toml` | Registre des fix temporaires (voir plus bas) |
| `docs/` | Documentation MkDocs, **FR (`docs/`) et EN (`docs/en/`)** |

## Où ajouter quoi

- **Paquet système commun** : groupe adapté dans `modules/nixos/packages/common.nix`.
  Paquet d'un seul hôte : `modules/nixos/packages/{desktop,laptop}.nix`. Jeux : `modules/nixos/gaming/`.
- **Stable par défaut** (`pkgs`). `pkgs-unstable` seulement pour une exception nommée et justifiée.
- **Paquet utilisateur / dotfile** : `modules/home/` (commun) ou `hosts/<hôte>/home.nix`.
- **Nouveau module** : un fichier par sujet, importé explicitement (`modules/nixos/default.nix` si commun,
  sinon dans `hosts/<hôte>/default.nix`).
- **Nouvel hôte** : `hosts/<nom>/` + une ligne dans `flake/hosts.nix` (voir `docs/hosts/adding-a-host.md`).
- Ne renomme pas un fichier copié dans le store (dotfiles, `.lua`, patches) sans raison : son nom fait
  partie du chemin du store.

## Vérifier un changement

Lis le code et le diff d'abord. Puis, dans cet ordre (toutes ces commandes sont autorisées) :

```sh
nix fmt                                   # formatage + deadnix + statix
nix run .#temp-fixes -- lint              # registre ↔ marqueurs TEMP-FIX
nix eval --raw .#nixosConfigurations.<hôte>.config.system.build.toplevel.drvPath
nix flake check --no-build                # les deux hôtes + checks
```

- Pour un **refactor pur**, le `drvPath` doit être identique avant/après. Sinon, compare avec
  `nix run nixpkgs#nix-diff -- <ancien.drv> <nouveau.drv>` et explique chaque différence dans le commit.
- `nix build --dry-run` montre ce qui serait compilé : signale toute compilation lourde (CUDA, noyau…).
- Les builds réels sont permis s'ils sont petits ; demande avant un build long.

**Interdit** sans demande explicite : `nixos-rebuild switch|boot`, `nh os switch|boot`, `sudo`,
`nix flake update` (le lock est mis à jour par la CI chaque semaine), garbage collection, `git push --force`.
C'est l'utilisateur qui reconstruit et active le système.

## Flux de travail

- Une branche par sujet, des commits atomiques, une PR. La CI (`.github/workflows/ci.yml`) lance le
  formatage, le lint, le registre et l'évaluation des deux hôtes.
- Tout changement de comportement met à jour la page de doc concernée, **en français et en anglais**.
- Commentaires : expliquer le *pourquoi* (contrainte, bug contourné), pas le *quoi*.

## Registre des fix temporaires

Tout contournement (paquet épinglé ou pris sur unstable, overlay correctif, option forcée avec
`mkForce` pour contrer un module, patch, flag de compatibilité…) **doit** :

1. avoir une entrée dans `temp-fixes.toml` (raison, condition de retrait, date de revue, test de retrait
   si possible) ;
2. porter un commentaire `TEMP-FIX(<id>)` à côté du code.

`temp-fixes lint` (et la CI) refusent un marqueur sans entrée, ou une entrée active sans marqueur.
La procédure complète (ajouter, revoir, résoudre) est dans `.claude/skills/temp-fixes/SKILL.md`.

**Challenger l'utilisateur** — c'est une attente explicite :

- **En début de session**, si des fix ont dépassé leur `review_after` (le hook `SessionStart` de Claude
  Code les injecte ; sinon lance `nix run .#temp-fixes -- due`), ouvre ta réponse en challengeant
  l'utilisateur sur **au plus deux** d'entre eux : est-il toujours nécessaire, quel test propose-tu
  (`temp-fixes check <id>`) ? Puis consigne sa réponse dans l'entrée (`last_challenged`, une ligne
  dans `history`, nouveau `review_after` ou passage en `resolved`).
- **Quand tu modifies un fichier portant un marqueur `TEMP-FIX`**, relis l'entrée et dis si le
  contournement est encore justifié.
- **Après une mise à jour de `flake.lock`**, lance `temp-fixes check --all` et rapporte les fix dont
  le test de retrait passe.
- Sois bref et concret ; n'insiste pas si l'utilisateur reporte, mais note la raison dans `history`.
