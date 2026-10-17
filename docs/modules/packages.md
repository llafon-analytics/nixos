# Paquets

## Paquets communs (`modules/nixos/packages/common.nix`)

Les paquets sont rangés dans des groupes nommés, concaténés dans `environment.systemPackages` :
`development`, `terminal`, `system`, `internet`, `office`, `multimedia`, `android`, `desktop`,
`archives`, `virtualisation`, `fun`. Voir [Groupes de paquets](../reference/package-groups.md).

Discord et Discord Canary (Vencord) viennent de `pkgs-unstable` et sont patchés par
`pkgs/discord-nvenc` (voir [GPU](gpu.md)).

## Jeux (`modules/nixos/gaming/default.nix`)

Steam (paquet Millennium), Gamescope, GameMode, Lutris et une liste d'outils pris volontairement
sur `pkgs-unstable` (Wine, Proton, MangoHud, Heroic, PrismLauncher, lsfg-vk…).

## Paquets par host

- `modules/nixos/packages/desktop.nix` : audio (`reaper`, `yabridge`), vidéo (`davinci-resolve`),
  `quickemu`, `phoronix-test-suite`, `sgdboop`, et `alvr` / `nvidia_oc` depuis unstable.
- `modules/nixos/packages/laptop.nix` : `powertop`, `radeontop`.

## Paquets locaux (`pkgs/`)

| Paquet | Rôle |
|---|---|
| `discord-nvenc` | Discord patché pour l'encodage NVENC |
| `opennow` | client GeForce NOW (AppImage) |
| `rtw89`, `rtw89-firmware` | pilote Wi-Fi hors arbre et firmware |
| `temp-fixes` | CLI du registre des fix temporaires |
| `mkdocs-env` | environnement Python de la documentation |

## Politique

- `pkgs` (stable) par défaut.
- `pkgs-unstable` seulement pour une exception nommée : paquet absent de stable ou qui doit suivre
  l'amont. Si c'est un contournement (stable cassé…), l'inscrire dans le
  [registre des fix temporaires](../reference/temp-fixes.md).
