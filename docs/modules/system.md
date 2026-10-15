# Configuration système (`configuration.nix`)

## Domaines couverts

- Boot/kernel (`systemd-boot`, `linuxPackages_6_18`, `v4l2loopback`)
- Réseau (`NetworkManager`, DNS Cloudflare, IPv6 désactivé)
- Locale/console (locale EN, clavier FR)
- Utilisateurs (`desktop`, `laptop`)
- Nix (flakes, registry, paquets non libres)
- Programmes (Hyprland, hyprlock, hypridle, yazi, corectrl)
- Audio (`pipewire`, PulseAudio désactivé)
- Stylix (thème, curseur, polices)

## Points notables

- Service Tailscale activé globalement.
- `system.stateVersion = "23.05"`.
