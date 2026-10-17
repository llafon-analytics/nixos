# Host `laptop`

## Imports (`hosts/laptop/default.nix`)

- `hardware.nix`
- `modules/nixos` (shared base)
- `modules/nixos/hardware/amdgpu.nix`, `modules/nixos/hardware/tlp.nix`, `modules/nixos/hardware/rtw89.nix`
- `modules/nixos/packages/laptop.nix` (`powertop`, `radeontop`)

## Specifics

- Hostname `laptop`, user `laptop` (the only declared account).
- Bluetooth enabled (`blueman`).
- 16 GiB swapfile (`/var/lib/swapfile`), `vm.swappiness = 20`, weekly TRIM through LUKS.
- TLP for power management (power-profiles-daemon disabled).
- Caps Lock disabled (hwdb).
- SDDM + Plasma 6, default session `hyprland`, autologin.
- Home Manager: `hosts/laptop/home.nix` (`moonlight-qt` from unstable, OpenPGP git signing, `ac` / `bat` aliases).
- Ports opened through Tailscale only (see [Ports](../reference/ports.md)).
