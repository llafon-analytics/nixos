# Troubleshooting

## Basic commands

```sh
nix flake show
nix flake check --no-build
git status        # the flake only sees files tracked by git
```

## Detailed trace

```sh
nix eval --show-trace .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
sudo nixos-rebuild dry-activate --flake .#desktop --show-trace
```

## Compare two states

```sh
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath   # before / after
nix run nixpkgs#nix-diff -- <old.drv> <new.drv>
```

## Common symptoms

| Symptom | Check |
|---|---|
| Flake error | `nix flake check --no-build` |
| New file "not found" | `git add` the file (flake) |
| Host not found | `nix flake show`, then `flake/hosts.nix` |
| Hyprland config | `nix build .#checks.x86_64-linux.hyprland-lua`, `hyprctl configerrors` |
| Service unreachable from another machine | it is only open on Tailscale: `tailscale status` |
| Network / Tailscale | `systemctl status tailscaled` then `tailscale status` |
