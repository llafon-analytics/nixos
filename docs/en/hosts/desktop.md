# Host `desktop`

## Imports

- `hardware-configuration-desktop.nix`
- `nvidiagpu.nix`
- `packages/desktop.nix`
- `drivers/rtw89.nix`

## Key specifics

- SSH enabled on port `2268`
- Docker + libvirtd + virt-manager enabled
- `vm.swappiness = 60`
- Normal NixOS CPU policy outside games; GameMode temporarily requests a performance profile without aggressive renice or I/O priority
- Stable kernel from the selected NixOS release
- SDDM + Plasma 6 + default session `hyprland`
- Discord and Discord Canary patched at the Nix package level for NVIDIA screen sharing

## Automatic gaming mode

GameMode keeps a conservative policy: performance governor and profile only
while gaming, split-lock mitigation disabled, with no renice, ioprio,
SCHED_ISO, CPU pinning, or core parking. Use this Steam launch option:

```sh
gamemoderun %command%
```

The first GameMode client atomically applies a lightweight Hyprland profile
without animations, rounding, transparency, blur, or shadows. It suspends
Syncthing only when its user unit was active, stops the running containers, and
then stops both `docker.service` and `docker.socket`. The last client reloads
the declarative Lua configuration and restores exactly the recorded services
and containers. Separate locked state is kept under `/run/user/$UID` and
`/run/gamemode-docker`.

Discord, EasyEffects, PipeWire/WirePlumber, Kitty, btop, Steam, Caelestia (bar and
wallpaper), Clipse, lactd, KDE Connect, Tailscale, and libvirt stay active. Both
monitors and VRR remain unchanged. Direct scanout is not forced on this
dual-monitor NVIDIA system: Hyprland 0.55.4 supports it, but this path needs
per-game runtime validation before it can be considered stable here.

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

The hook timeout is 120 seconds: containers get up to 15 seconds for a clean
stop and the restored daemon gets up to 30 seconds to become available, while
the overall operation remains bounded.
