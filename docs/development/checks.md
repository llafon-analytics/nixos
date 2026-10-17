# Checks

## Commandes

```sh
nix fmt                                   # formate et corrige (nixfmt, deadnix, statix, shfmt, stylua)
nix fmt -- --ci                           # vérifie sans modifier (shellcheck et actionlint inclus)
nix run .#temp-fixes -- lint              # registre des fix temporaires ↔ marqueurs TEMP-FIX
nix flake check --no-build                # évalue tous les checks, dont les deux systèmes
```

## Checks de la flake (`flake/checks.nix`)

| Check | Contenu |
|---|---|
| `desktop`, `laptop` | `system.build.toplevel` de chaque host (évalué par `--no-build`) |
| `treefmt` | le dépôt est formaté et passe les linters |
| `temp-fixes-lint` | le registre `temp-fixes.toml` est cohérent avec les marqueurs du code |
| `hyprland-lua` | syntaxe (`luac -p`) de `hyprland.base.lua` et des `hyprland.lua` des hosts |

Construire les checks légers :

```sh
nix build .#checks.x86_64-linux.{treefmt,temp-fixes-lint,hyprland-lua}
```

## Vérifier un refactor

Un refactor pur ne doit pas changer le système : comparer le `drvPath` avant/après.

```sh
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix run nixpkgs#nix-diff -- <ancien.drv> <nouveau.drv>   # si différent
```
