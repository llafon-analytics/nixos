# Graphe des modules

```mermaid
flowchart LR
  subgraph Commun["modules/nixos (default.nix)"]
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

  D --> Commun
  L --> Commun
  DH --> HC[modules/home/common.nix]
  LH --> HC
```

## À retenir

- Tout ce qui est commun passe par `modules/nixos/default.nix`.
- Le matériel est importé explicitement par chaque host (`modules/nixos/hardware/`).
- Côté utilisateur, `modules/home/common.nix` importe tous les modules Home Manager partagés.
