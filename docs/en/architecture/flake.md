# Flake

`flake.nix` only declares the **inputs**; outputs are defined with
[flake-parts](https://flake.parts):

| File | Outputs |
|---|---|
| `flake/hosts.nix` | `nixosConfigurations.{desktop,laptop}` through `lib/mkHost.nix` |
| `flake/packages.nix` | `packages.x86_64-linux.{temp-fixes,mkdocs-env,opennow}` |
| `flake/checks.nix` | `checks.x86_64-linux.{desktop,laptop,temp-fixes-lint,hyprland-lua}` |
| `flake/treefmt.nix` | `formatter` (`nix fmt`) and `checks.x86_64-linux.treefmt` |
| `flake/devshell.nix` | `devShells.x86_64-linux.default` (`nix develop`) |

## `lib/mkHost.nix`

Builds `nixpkgs.lib.nixosSystem` for `hosts/<name>` and passes as `specialArgs`:

- `inputs`: every flake input;
- `pkgs-unstable`: `nixpkgs-unstable` instantiated with `allowUnfree`.

Home Manager gets the same arguments (`home-manager.extraSpecialArgs`) and uses the system package
set (`useGlobalPkgs = true`).

## Stable / unstable policy

- `nixpkgs` (`nixos-26.05`) is the base; `home-manager` and `stylix` follow the same release.
- `pkgs-unstable` is reserved for named exceptions (fast-moving gaming packages, Discord…).

See also [Inputs](../reference/inputs.md).
