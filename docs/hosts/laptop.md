# Host `laptop`

## Imports (`hosts/laptop/default.nix`)

- `hardware.nix`
- `modules/nixos` (socle commun)
- `modules/nixos/hardware/amdgpu.nix`, `modules/nixos/hardware/tlp.nix`, `modules/nixos/hardware/rtw89.nix`
- `modules/nixos/packages/laptop.nix` (`powertop`, `radeontop`)

## Particularités

- Hostname `laptop`, utilisateur `laptop` (seul compte déclaré).
- Bluetooth activé (`blueman`).
- Swapfile de 16 GiB (`/var/lib/swapfile`), `vm.swappiness = 20`, TRIM hebdomadaire à travers LUKS.
- TLP pour la gestion d'énergie (power-profiles-daemon désactivé).
- Caps Lock désactivé (hwdb).
- SDDM + Plasma 6, session par défaut `hyprland`, autologin.
- Home Manager : `hosts/laptop/home.nix` (`moonlight-qt` depuis unstable, signature git OpenPGP, alias `ac` / `bat`).
- Ports ouverts uniquement via Tailscale (voir [Ports](../reference/ports.md)).
