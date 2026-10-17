# Services

## Services système (socle commun)

| Service | État | Module |
|---|---|---|
| `services.tailscale` | activé (`--ssh`) | `modules/nixos/network.nix` |
| `services.flatpak` | activé | `modules/nixos/desktop/default.nix` |
| `services.printing`, `services.avahi`, `services.ipp-usb` | activés | `modules/nixos/printing.nix` |
| `services.udisks2`, `services.dbus` | activés | `modules/nixos/base/system.nix` |
| `services.emacs` | activé (éditeur par défaut) | `modules/nixos/desktop/apps.nix` |
| `services.hypridle` | **désactivé** (Caelestia gère la veille) | `modules/nixos/desktop/default.nix` |

## Services par host

### Desktop

- `services.openssh` sur le port `2268` (via Tailscale uniquement)
- `virtualisation.docker` (`live-restore = false`, arrêt en 10 s), `virtualisation.libvirtd`
- `lactd` (LACT)
- `services.fstrim` hebdomadaire

### Laptop

- `services.blueman`
- `services.tlp` (`modules/nixos/hardware/tlp.nix`)
- `services.fstrim` hebdomadaire

## Pare-feu

Aucun port de service n'est ouvert globalement : chaque host ouvre ses ports sur `tailscale0`
seulement. Restent ouverts sur le réseau local : UDP 41641 (connexions Tailscale directes),
mDNS (Avahi, découverte des imprimantes) et KDE Connect (1714-1764).

!!! warning "Docker contourne le pare-feu NixOS"
    Un port publié par un conteneur (`-p 6379:6379`) est joignable depuis le réseau local quelle
    que soit la configuration du pare-feu. Publier sur `127.0.0.1` ou sur l'adresse Tailscale.
