# Inputs de la flake

## Inputs déclarés

| Input | Source | Usage principal |
|---|---|---|
| `nixpkgs` | `github:nixos/nixpkgs/nixos-26.05` | base stable par défaut pour les packages/modules |
| `nixpkgs-unstable` | `github:NixOS/nixpkgs/nixpkgs-unstable` | exceptions rapides explicites, principalement gaming/compatibilité |
| `home-manager` | `github:nix-community/home-manager/release-26.05` | configuration utilisateur, suit `nixpkgs` |
| `stylix` | `github:danth/stylix/release-26.05` | theming aligné sur la branche stable, suit `nixpkgs` |
| `flake-parts` | `github:hercules-ci/flake-parts` | structure des sorties de la flake |
| `treefmt-nix` | `github:numtide/treefmt-nix` | formatter et lint (`nix fmt`) |
| `nix-craftapps` | `github:olafkfreund/nix-craftapps` | Photocraft (desktop), suit `nixpkgs` |
| `codex-cli-nix` | `github:sadjow/codex-cli-nix` | paquet `codex`, suit `nixpkgs-unstable` |
| `claude-code-nix` | `github:sadjow/claude-code-nix` | paquet `claude`, suit `nixpkgs-unstable` |
| `caelestia-shell` | `github:caelestia-dots/shell` | shell Caelestia (barre, launcher, verrouillage), suit `nixpkgs-unstable` |
| `millennium` | `github:SteamClientHomebrew/Millennium/next?dir=packages/nix` | overlay et package Steam patché par Millennium |
| `zen-browser` | `github:0xc000022070/zen-browser-flake` | paquet et module Home Manager du navigateur (canal beta, suit `nixpkgs-unstable`) |
| `nix-index-database` | `github:nix-community/nix-index-database` | base nix-index pré-construite (hebdo) pour comma et command-not-found, suit `nixpkgs` |
| `catppuccin-zen` | `github:catppuccin/zen-browser` (non-flake) | CSS et logo Catppuccin Latte, accent Pink, pour Zen |

## Vérifier les versions lockées

```sh
nix flake metadata
```

ou consulter directement `flake.lock`.

## Policy branches

- Garder `nixpkgs`, `home-manager` et `stylix` alignés sur la même release stable.
- Ne pas ajouter de nouvel input stable parallèle : `nixpkgs` est déjà la base stable.
- Ajouter `inputs.nixpkgs.follows` aux nouveaux inputs quand c'est possible, pour ne pas
  multiplier les copies de nixpkgs dans `flake.lock`.
- Utiliser `nixpkgs-unstable` uniquement pour une exception nommée et localisée.

## Zen Browser

- Le module partagé `modules/home/zen-browser.nix` active Zen via Home Manager et applique Catppuccin Latte avec l'accent Pink.
- Zen utilise seul `nixpkgs-unstable`, conformément à la recommandation de son flake pour la compatibilité avec les versions Firefox récentes.
- Les CSS et `zen-logo-latte.svg` proviennent directement de l'input verrouillé `catppuccin-zen`; aucun téléchargement au démarrage du navigateur n'est nécessaire.

## Fixes suivis

### Millennium

- Source officielle: <https://docs.steambrew.app/users/getting-started/installation>
- Megathread NixOS: <https://github.com/SteamClientHomebrew/Millennium/issues/551>
- Fix appliqué: `millennium.inputs.nixpkgs.follows = "nixpkgs-unstable";`.
- Raison: le megathread NixOS recommande la branche `next` de Millennium. Faire suivre `nixpkgs-unstable` à Millennium garde son packaging sur une base récente sans basculer tout le système stable.
- Workaround local retiré: l'overlay `overlays/millennium-compat.nix` et la copie locale du packaging ont été supprimés pour revenir au packaging officiel.
- Note de maintenance: utiliser la branche `next` et, après l'ajout ou la mise à jour de cet input, mettre à jour le lock avec `nix flake update millennium`.
