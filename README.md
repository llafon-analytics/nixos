# NixOS configuration (flake)

[![CI](https://github.com/llafon-analytics/nixos/actions/workflows/ci.yml/badge.svg)](https://github.com/llafon-analytics/nixos/actions/workflows/ci.yml)

Configuration NixOS personnelle pour deux machines (`desktop` et `laptop`) avec Home Manager,
Stylix, Hyprland et Caelestia.

## Arborescence

| Chemin | Contenu |
|---|---|
| `flake.nix`, `flake/`, `lib/` | inputs, sorties (flake-parts), fabrique des hosts |
| `hosts/<host>/` | système, matériel, Home Manager et Hyprland propres à chaque machine |
| `modules/nixos/`, `modules/home/` | modules partagés |
| `pkgs/`, `overlays/`, `dotfiles/`, `scripts/` | paquets locaux, overlays, fichiers de config, scripts |
| `temp-fixes.toml` | registre des fix temporaires |
| `AGENTS.md` | consignes pour les agents IA |

## Commandes usuelles

```sh
nix develop                      # outils : formatter, linters, nixd, temp-fixes, MkDocs
nix fmt                          # formater et linter
nix flake check --no-build       # évaluer les deux machines et les checks
temp-fixes list                  # fix temporaires en cours

nh os switch                     # reconstruire la machine courante
sudo nixos-rebuild switch --flake .#desktop   # ou .#laptop
```

## Documentation

Documentation MkDocs en **français** et en **anglais** :

- Français : [`docs/index.md`](docs/index.md)
- English : [`docs/en/index.md`](docs/en/index.md)

```sh
nix develop -c mkdocs serve      # prévisualiser
nix develop -c mkdocs build --strict
```
