# Packages

## Shared packages (`modules/nixos/packages/common.nix`)

Packages are sorted into named groups, concatenated into `environment.systemPackages`:
`development`, `terminal`, `system`, `internet`, `office`, `multimedia`, `android`, `desktop`,
`archives`, `virtualisation`, `fun`. See [Package groups](../reference/package-groups.md).

Discord and Discord Canary (Vencord) come from `pkgs-unstable` and are patched by
`pkgs/discord-nvenc` (see [GPU](gpu.md)).

## Gaming (`modules/nixos/gaming/default.nix`)

Steam (Millennium package), Gamescope, GameMode, Lutris and a list of tools deliberately taken from
`pkgs-unstable` (Wine, Proton, MangoHud, Heroic, PrismLauncher, lsfg-vk…).

## Per-host packages

- `modules/nixos/packages/desktop.nix`: audio (`reaper`, `yabridge`), video (`davinci-resolve`),
  `quickemu`, `phoronix-test-suite`, `sgdboop`, and `alvr` / `nvidia_oc` from unstable.
- `modules/nixos/packages/laptop.nix`: `powertop`, `radeontop`.

## Local packages (`pkgs/`)

| Package | Role |
|---|---|
| `discord-nvenc` | Discord patched for NVENC encoding |
| `opennow` | GeForce NOW client (AppImage) |
| `rtw89`, `rtw89-firmware` | out-of-tree Wi-Fi driver and firmware |
| `temp-fixes` | CLI for the temporary-fix registry |
| `mkdocs-env` | Python environment for the documentation |

## Policy

- `pkgs` (stable) by default.
- `pkgs-unstable` only for a named exception: package missing from stable or that must follow
  upstream. If it is a workaround (stable broken…), record it in the
  [temporary-fix registry](../reference/temp-fixes.md).
