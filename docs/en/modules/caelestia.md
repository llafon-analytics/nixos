# Caelestia

[Caelestia Shell](https://github.com/caelestia-dots/shell) replaces HyprPanel, which is
no longer maintained. It is a Quickshell/QML shell for Hyprland providing the bar,
notifications, launcher, lockscreen and wallpaper.

## Wiring

| Location | Role |
|---|---|
| `flake.nix` | `caelestia-shell` input, with `inputs.nixpkgs.follows = "nixpkgs-unstable"` |
| `common-modules.nix` | `inputs.caelestia-shell.homeManagerModules.default` in `home-manager.sharedModules` |
| `hm/caelestia.nix` | shared module, imported by `home-desktop.nix` and `home-laptop.nix` |

The `follows` points at `nixpkgs-unstable` rather than `nixpkgs`: Caelestia builds on
`quickshell` (git), which tracks nixos-unstable. Pinning it to stable 26.05 is the
likeliest way to break the build.

The shell is started by its own systemd user service
(`programs.caelestia.systemd`), bound to `graphical-session.target` — so there is no
`exec-once` in `hyprland.base.lua`.

## Theming

Caelestia ships a built-in `catppuccin` scheme with all four flavours. We pin
`catppuccin` / `latte` / `light` mode (Latte only exists as light) to stay aligned with
Stylix.

The scheme is runtime state (`~/.local/state/caelestia/scheme.json`) whose colour values
are computed by the CLI, not a declarative file. It is therefore re-applied on every
Home Manager activation:

```sh
caelestia scheme set -n catppuccin -f latte -m light
```

!!! warning "Coexisting with Stylix"
    Left at their defaults, the Caelestia CLI rewrites `gtk.css`, the Hyprland colours,
    `btop.conf` and terminal colour sequences on **every** scheme change, colliding with
    Stylix's read-only symlinks. All `cli.settings.theme.enable*` flags are therefore
    `false` in `hm/caelestia.nix`: Caelestia only themes its own UI.

    Regression check: `~/.config/gtk-3.0/gtk.css` and `~/.config/btop/btop.conf` must stay
    symlinks into `/nix/store`. If either became a regular file, an `enable*` was missed.

## Keybinds

| Keybind | Action |
|---|---|
| `SUPER + space` | launcher |
| `SUPER + M` | dashboard |
| `SUPER + B` | sidebar (notifications) |
| `SUPER + X` | lock |
| `SUPER + W` | window switcher — **rofi**, Caelestia has no equivalent |

Volume and brightness keys stay on `pamixer` / `brightnessctl`; Caelestia renders its
OSD on top.

## Lockscreen

`hypridle.conf` uses:

```
lock_cmd = if systemctl --user is-active --quiet caelestia; then caelestia shell lock lock; elif ! pidof hyprlock >/dev/null; then hyprlock; fi
```

Caelestia's lock lives inside the shell process: if the shell is not running the session
must not stay unlocked, hence the hyprlock fallback (kept, along with `hm/hyprlock/`).

!!! danger "Never run hyprlock while Caelestia is running"
    Known upstream bug ([shell#988](https://github.com/caelestia-dots/shell/issues/988)):
    hyprlock crashes the shell. Hence the explicit systemd check rather than a plain
    `caelestia ... || hyprlock`: a non-zero exit from Caelestia must never fire hyprlock
    while the shell is up.

Caelestia uses its own `pam.d/passwd` (`pam_faillock` + `pam_unix`) via
`pam_start_confdir`, bypassing `/etc/pam.d`. If unlocking fails, add
`security.pam.services.caelestia = {};` to `configuration.nix`.

## Wallpaper

`paths.wallpaperDir` points at `~/Pictures/Wallpapers`, populated by `home.file` from
`hm/wallpaper/`. Initial selection, once the session is up:

```sh
caelestia wallpaper -f ~/Pictures/Wallpapers/wall3.png
caelestia shell wallpaper get
```

The choice is then persisted in Caelestia's state and changeable from the launcher.

## Settings

`programs.caelestia.settings` is deliberately minimal. Upstream keys (`bar.*`,
`services.gpuType`, `bar.statusIcons`, `appearance.*`) are not stably documented and
**an unknown key is silently ignored**. Do not guess them: read the effective values
after a first launch, then add only what is actually wanted.

```sh
caelestia shell -s          # list IPC targets
caelestia shell drawers list
caelestia scheme get
systemctl --user status caelestia
journalctl --user -u caelestia -e
```
