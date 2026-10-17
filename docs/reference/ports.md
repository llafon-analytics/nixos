# Ports

Les ports de service sont ouverts en TCP et UDP **sur l'interface `tailscale0` uniquement**.

## Desktop

Liste dans `hosts/desktop/ports.nix` :
`22, 80, 91, 443, 444, 2268, 4747, 5037, 5555, 6379, 7777, 7878, 8080, 8096, 8211, 8501, 8777, 8989, 9100, 27015, 47984, 47989, 47990, 47998, 47999, 48000, 48002, 48010, 48100, 48200`.

SSH écoute sur `2268`.

## Laptop

`80, 91, 443, 444, 8501, 9100` (dans `hosts/laptop/default.nix`).

## Ouverts sur toutes les interfaces

| Port | Raison |
|---|---|
| UDP 41641 | connexions directes Tailscale |
| UDP 5353 | mDNS (Avahi, découverte des imprimantes) |
| TCP/UDP 1714-1764 | KDE Connect |

Les ports publiés par Docker contournent le pare-feu NixOS (voir [Services](../modules/services.md)).
