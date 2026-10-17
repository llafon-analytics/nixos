# Checks

## Commands

```sh
nix fmt                                   # format and fix (nixfmt, deadnix, statix, shfmt, stylua)
nix fmt -- --ci                           # check without modifying (shellcheck and actionlint included)
nix run .#temp-fixes -- lint              # temporary-fix registry <-> TEMP-FIX markers
nix flake check --no-build                # evaluate every check, both systems included
```

## Flake checks (`flake/checks.nix`)

| Check | Content |
|---|---|
| `desktop`, `laptop` | each host's `system.build.toplevel` (evaluated by `--no-build`) |
| `treefmt` | the repository is formatted and passes the linters |
| `temp-fixes-lint` | `temp-fixes.toml` agrees with the markers in the code |
| `hyprland-lua` | syntax (`luac -p`) of `hyprland.base.lua` and the hosts' `hyprland.lua` |

Build the lightweight checks:

```sh
nix build .#checks.x86_64-linux.{treefmt,temp-fixes-lint,hyprland-lua}
```

## Checking a refactor

A pure refactor must not change the system: compare the `drvPath` before/after.

```sh
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix run nixpkgs#nix-diff -- <old.drv> <new.drv>   # if it differs
```
