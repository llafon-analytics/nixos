# Services

## System services (shared base)

| Service | State | Module |
|---|---|---|
| `services.tailscale` | enabled (`--ssh`) | `modules/nixos/network.nix` |
| `services.flatpak` | enabled | `modules/nixos/desktop/default.nix` |
| `services.printing`, `services.avahi`, `services.ipp-usb` | enabled | `modules/nixos/printing.nix` |
| `services.udisks2`, `services.dbus` | enabled | `modules/nixos/base/system.nix` |
| `services.emacs` | enabled (default editor) | `modules/nixos/desktop/apps.nix` |
| `services.hypridle` | **disabled** (Caelestia handles idle) | `modules/nixos/desktop/default.nix` |

## Per-host services

### Desktop

- `services.openssh` on port `2268` (through Tailscale only)
- `virtualisation.docker` (`live-restore = false`, 10 s shutdown), `virtualisation.libvirtd`
- `lactd` (LACT)
- weekly `services.fstrim`

### Laptop

- `services.blueman`
- `services.tlp` (`modules/nixos/hardware/tlp.nix`)
- weekly `services.fstrim`

## Firewall

No service port is opened globally: each host opens its ports on `tailscale0` only. Still open on
the local network: UDP 41641 (direct Tailscale connections), mDNS (Avahi, printer discovery) and
KDE Connect (1714-1764).

!!! warning "Docker bypasses the NixOS firewall"
    A port published by a container (`-p 6379:6379`) is reachable from the local network whatever
    the firewall says. Publish on `127.0.0.1` or on the Tailscale address instead.
