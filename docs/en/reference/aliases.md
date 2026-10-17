# Aliases

This repository defines shared aliases in `hm/zsh.nix` and host-specific aliases in `home-desktop.nix` / `home-laptop.nix`.

## Shared aliases (`hm/zsh.nix`)

| Alias | Command |
|---|---|
| `nd` | runs `nix develop -c zsh` to enter a Nix dev shell while keeping zsh |

`dupdate` / `lupdate` rebuild the desktop / laptop configuration with
`nh os switch ~/Documents/nix-configuration -H <host> --show-trace`.

## Command-line tools (`hm/cli-tools.nix`)

| Command | Purpose |
|---|---|
| `Ctrl+R` | Atuin history search (Enter puts the command back in the prompt) |
| `z <pattern>` / `zi` | jump to a frequent directory (zoxide) / interactive fzf picker |
| `lg` | Lazygit; on exit the shell follows the repository you opened |
| `lazydocker` | Docker containers (desktop only) |
| `nh os switch` | rebuild the current host (`NH_OS_FLAKE` points at `~/Documents/nix-configuration#<host>`) |
| `nh os test` / `nh os boot` | same as `nixos-rebuild test` / `boot` |
| `nh clean all --keep 5` | manual generation and store cleanup (nothing runs automatically) |
| `nh search <pattern>` | search nixpkgs |
| `, <command>` | run a nixpkgs command without installing it (comma) |

`nh` bundles nix-output-monitor (build tree) and shows a package diff before
activation, so nom is not installed separately. Fallback without nh:
`sudo nixos-rebuild switch --flake ~/Documents/nix-configuration#desktop`.

Atuin stays local: no sync, no update check, AI integration disabled. The Up
arrow keeps zsh's native history. To import the existing zsh history once:
`atuin import auto`.

An unknown command suggests the nixpkgs package providing it (nix-index, using
the prebuilt `nix-index-database`).

## direnv

To automatically load a flake in a repository:

```sh
echo "use flake" > .envrc
direnv allow
```
