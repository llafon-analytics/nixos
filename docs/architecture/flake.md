# Flake

`flake.nix` ne déclare que les **inputs** et délègue les sorties à
[flake-parts](https://flake.parts) :

| Fichier | Sorties |
|---|---|
| `flake/hosts.nix` | `nixosConfigurations.{desktop,laptop}` via `lib/mkHost.nix` |
| `flake/packages.nix` | `packages.x86_64-linux.{temp-fixes,mkdocs-env,opennow}` |
| `flake/checks.nix` | `checks.x86_64-linux.{desktop,laptop,temp-fixes-lint,hyprland-lua}` |
| `flake/treefmt.nix` | `formatter` (`nix fmt`) et `checks.x86_64-linux.treefmt` |
| `flake/devshell.nix` | `devShells.x86_64-linux.default` (`nix develop`) |

## `lib/mkHost.nix`

Construit `nixpkgs.lib.nixosSystem` pour `hosts/<nom>` et passe en `specialArgs` :

- `inputs` : tous les inputs de la flake ;
- `pkgs-unstable` : `nixpkgs-unstable` instancié avec `allowUnfree`.

Home Manager reçoit les mêmes arguments (`home-manager.extraSpecialArgs`) et utilise le jeu de
paquets du système (`useGlobalPkgs = true`).

## Politique stable / unstable

- `nixpkgs` (`nixos-26.05`) est la base ; `home-manager` et `stylix` suivent la même release.
- `pkgs-unstable` est réservé à des exceptions nommées (paquets gaming rapides, Discord…).

Voir aussi [Inputs](../reference/inputs.md).
