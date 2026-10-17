# Vue d'ensemble

La flake expose deux configurations NixOS, `desktop` et `laptop`, construites par la même fabrique
(`lib/mkHost.nix`). Chaque host importe le socle commun (`modules/nixos`) puis ajoute son matériel,
son utilisateur et ses modules propres.

```mermaid
flowchart TD
  F[flake.nix] --> P[flake/*.nix<br/>flake-parts]
  P --> MK[lib/mkHost.nix]
  MK --> HD[hosts/desktop]
  MK --> HL[hosts/laptop]

  HD --> MN[modules/nixos<br/>socle commun]
  HL --> MN
  HD --> HWD[matériel desktop<br/>nvidia, rtw89, gamemode]
  HL --> HWL[matériel laptop<br/>amdgpu, tlp, rtw89]

  HD --> HMD[hosts/desktop/home.nix]
  HL --> HML[hosts/laptop/home.nix]
  HMD --> MH[modules/home/common.nix]
  HML --> MH
```

## Principes

1. **Socle commun** (`modules/nixos`) : boot, Nix, locale, réseau, bureau, impression, jeux, paquets.
2. **Spécificités par machine** (`hosts/<host>`) : matériel, utilisateur, ports, services propres.
3. **Session utilisateur** : Home Manager, avec `modules/home/common.nix` partagé et un `home.nix`
   par host pour les différences.
4. **Contournements tracés** : chaque fix temporaire est inscrit dans `temp-fixes.toml`
   (voir [Fix temporaires](../reference/temp-fixes.md)).
