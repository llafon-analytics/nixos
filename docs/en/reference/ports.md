# Ports

Service ports are opened over TCP and UDP **on the `tailscale0` interface only**.

## Desktop

List in `hosts/desktop/ports.nix`:
`22, 80, 91, 443, 444, 2268, 4747, 5037, 5555, 6379, 7777, 7878, 8080, 8096, 8211, 8501, 8777, 8989, 9100, 27015, 47984, 47989, 47990, 47998, 47999, 48000, 48002, 48010, 48100, 48200`.

SSH listens on `2268`.

## Laptop

`80, 91, 443, 444, 8501, 9100` (in `hosts/laptop/default.nix`).

## Open on every interface

| Port | Reason |
|---|---|
| UDP 41641 | direct Tailscale connections |
| UDP 5353 | mDNS (Avahi, printer discovery) |
| TCP/UDP 1714-1764 | KDE Connect |

Ports published by Docker bypass the NixOS firewall (see [Services](../modules/services.md)).
