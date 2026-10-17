# Module graph

```mermaid
flowchart LR
  subgraph Common["modules/nixos (default.nix)"]
    EXT[stylix, home-manager,<br/>nix-index-database]
    BASE[base/: boot, locale, nix, system, users]
    NET[network.nix]
    HM[home-manager.nix]
    DESK[desktop/: hyprland, audio, fonts,<br/>stylix, xdg-portal, apps]
    PRN[printing.nix]
    GAME[gaming/]
    LOGI[hardware/logitech.nix]
    PKG[packages/common.nix]
  end

  subgraph Desktop["hosts/desktop"]
    D[default.nix] --> DHW[hardware.nix]
    D --> NV[hardware/nvidia.nix]
    D --> RTW[hardware/rtw89.nix]
    D --> GMO[gaming/gamemode-optimizations.nix]
    D --> PD[packages/desktop.nix]
    D --> DH[home.nix]
  end

  subgraph Laptop["hosts/laptop"]
    L[default.nix] --> LHW[hardware.nix]
    L --> AMD[hardware/amdgpu.nix]
    L --> TLP[hardware/tlp.nix]
    L --> RTW2[hardware/rtw89.nix]
    L --> PL[packages/laptop.nix]
    L --> LH[home.nix]
  end

  D --> Common
  L --> Common
  DH --> HC[modules/home/common.nix]
  LH --> HC
```

## Key points

- Everything shared goes through `modules/nixos/default.nix`.
- Hardware is imported explicitly by each host (`modules/nixos/hardware/`).
- On the user side, `modules/home/common.nix` imports every shared Home Manager module.
