# Host `desktop`

## Imports (`hosts/desktop/default.nix`)

- `hardware.nix`
- `modules/nixos` (shared base)
- `modules/nixos/hardware/nvidia.nix`, `modules/nixos/hardware/rtw89.nix`
- `modules/nixos/gaming/gamemode-optimizations.nix`
- `modules/nixos/packages/desktop.nix`
- `nix-craftapps` module (Photocraft)

## Specifics

- Hostname `desktop`, user `desktop` (the only declared account).
- SSH on port `2268`, reachable through Tailscale only.
- Docker + libvirtd + virt-manager, `nvidia-container-toolkit`.
- `vm.swappiness = 60`, weekly TRIM through LUKS.
- Global `cudaSupport` (see [GPU](../modules/gpu.md)).
- LACT (`lactd`) for NVIDIA monitoring/overclocking.
- SDDM + Plasma 6, default session `hyprland`, autologin.
- Home Manager: `hosts/desktop/home.nix` (OBS with CUDA, lazydocker, `valheim` alias, Catppuccin rofi theme).

## Automatic game mode

GameMode keeps a conservative policy: performance governor and profile only
while playing, split-lock mitigation disabled, no renice, ioprio, SCHED_ISO,
pinning or core parking. Steam launch option:

```sh
gamemoderun %command%
```

The first GameMode client atomically applies a Hyprland profile without
animations, rounding, transparency, blur or shadows. It suspends Syncthing only
if its user unit was active, stops running containers, then stops
`docker.service` and `docker.socket`. The last client reloads the declarative
Lua configuration and restores exactly the recorded services and containers.
States are locked and stored separately under `/run/user/$UID` and
`/run/gamemode-docker`.

Both scripts live in `scripts/gamemode/` and are packaged by
`modules/nixos/gaming/gamemode-optimizations.nix` (`writeShellApplication`, checked by shellcheck).

Discord, EasyEffects, PipeWire/WirePlumber, Kitty, btop, Steam, Caelestia (bar and
wallpaper), Clipse, lactd, KDE Connect, Tailscale and libvirt keep running. Both
monitors and VRR are left untouched. Direct scanout is not forced on this
dual-monitor NVIDIA machine: Hyprland 0.55.4 supports it, but that path must be
validated game by game before being considered stable here.

Test without a game:

```sh
gamemoderun sleep 60
```

Diagnostics:

```sh
gamemoded -s
gamemoded -t
journalctl --user -u gamemoded
systemctl status docker.service docker.socket
docker ps --no-trunc
systemctl --user status syncthing.service
hyprctl instances
hyprctl getoption animations.enabled
hyprctl getoption decoration.blur.enabled
hyprctl getoption decoration.shadow.enabled
hyprctl getoption decoration.rounding
```

The hook timeout is 120 seconds: up to 15 seconds for containers to stop cleanly
and up to 30 seconds for the restored daemon to become available, while keeping
a finite bound.

## Firewall

Ports are listed in `hosts/desktop/ports.nix` and opened over TCP/UDP **on the `tailscale0`
interface only**. See [Ports](../reference/ports.md).
