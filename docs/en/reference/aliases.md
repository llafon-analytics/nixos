# Aliases

## Shared aliases (`modules/home/zsh.nix`)

| Alias | Command |
|---|---|
| `doom` | `~/.config/emacs/bin/doom` |
| `dupdate` | `nh os switch --hostname desktop --show-trace` |
| `lupdate` | `nh os switch --hostname laptop --show-trace` |
| `nd` | runs `nix develop -c zsh` to enter a Nix dev shell while keeping zsh |
| `v4l2loopback-ctl0` | virtual camera `/dev/video0` as YU12 1280x720 @ 60 fps |
| `v4l2loopback-ctl1` | same for `/dev/video1` |
| `skb` | switch the Hyprland keyboard layout |
| `extract` | `~/extract.sh` |
| `dpms` | cycle Hyprland DPMS |

## Command-line tools (`modules/home/cli-tools.nix`)

| Command | Role |
|---|---|
| `Ctrl+R` | Atuin history search (Enter puts the command back in the prompt) |
| `z <pattern>` / `zi` | jump to a frequent directory (zoxide) / interactive fzf picker |
| `lg` | Lazygit; on exit the shell follows the repository you were in |
| `lazydocker` | Docker containers (desktop only) |
| `nh os switch` | rebuild the current host (`NH_OS_FLAKE` points at `~/Documents/nix-configuration`, the configuration follows the hostname) |
| `nh os test` / `nh os boot` | equivalents of `nixos-rebuild test` / `boot` |
| `nh clean all --keep 5` | manual cleanup of generations and the store (no automatic cleanup) |
| `nh search <pattern>` | search nixpkgs |
| `, <command>` | run a nixpkgs command without installing it (comma) |
| `temp-fixes` | temporary-fix registry (see [Temporary fixes](temp-fixes.md)) |
| `mute-discord` | mute/unmute Discord in PipeWire (`SUPER + ;`) |
| `satty-shot` | annotated region screenshot with satty (`CTRL + Print`) |

`nh` wraps nix-output-monitor (build tree) and shows the package diff before
activation, so nom is not installed separately. Fallback without nh:
`sudo nixos-rebuild switch --flake ~/Documents/nix-configuration#desktop`.

Atuin stays local: no sync, no update check, AI integration disabled. The Up arrow
keeps zsh's native history. To import the existing zsh history (once):
`atuin import auto`.

An unknown command suggests the nixpkgs package that provides it (nix-index, with
the prebuilt `nix-index-database`).

## direnv

The repository ships an `.envrc` (`use flake`): `direnv allow` loads the devShell. For another
repository:

```sh
echo "use flake" > .envrc
direnv allow
```

## Host-specific aliases

| Host | Alias | Command |
|---|---|---|
| desktop | `valheim` | starts Valheim with gamemoderun/mangohud |
| laptop | `ac` | `sudo tlp ac` |
| laptop | `bat` | `sudo tlp start` |
