# Overview

The flake exposes two NixOS configurations, `desktop` and `laptop`, built by the same function
(`lib/mkHost.nix`). Each host imports the shared base (`modules/nixos`) and adds its hardware, its
user and its own modules.

```mermaid
flowchart TD
  F[flake.nix] --> P[flake/*.nix<br/>flake-parts]
  P --> MK[lib/mkHost.nix]
  MK --> HD[hosts/desktop]
  MK --> HL[hosts/laptop]

  HD --> MN[modules/nixos<br/>shared base]
  HL --> MN
  HD --> HWD[desktop hardware<br/>nvidia, rtw89, gamemode]
  HL --> HWL[laptop hardware<br/>amdgpu, tlp, rtw89]

  HD --> HMD[hosts/desktop/home.nix]
  HL --> HML[hosts/laptop/home.nix]
  HMD --> MH[modules/home/common.nix]
  HML --> MH
```

## Principles

1. **Shared base** (`modules/nixos`): boot, Nix, locale, network, desktop, printing, gaming, packages.
2. **Per-machine specifics** (`hosts/<host>`): hardware, user, ports, own services.
3. **User session**: Home Manager, with a shared `modules/home/common.nix` and one `home.nix` per
   host for the differences.
4. **Tracked workarounds**: every temporary fix is recorded in `temp-fixes.toml`
   (see [Temporary fixes](../reference/temp-fixes.md)).
