# Home Manager

## Organisation

- `modules/nixos/home-manager.nix` : intégration NixOS (`useGlobalPkgs = true`,
  `useUserPackages = true`, sauvegarde `.backup`, modules HM de Zen et Caelestia).
- `modules/home/common.nix` : tout ce que les deux utilisateurs partagent ; il importe
  `caelestia.nix`, `zen-browser.nix`, `vscode.nix`, `zsh.nix`, `cli-tools.nix` (Atuin, zoxide,
  Lazygit, nh), `pyprland.nix`, `neovim.nix`, `fastfetch.nix` et `hyprland/`.
- `hosts/<host>/home.nix` : les différences propres à chaque host.

Home Manager utilise le jeu de paquets du système : mêmes overlays, même `allowUnfree` et, sur le
desktop, même `cudaSupport` (voir le fix temporaire `obs-backgroundremoval-cpu`).

## Fichiers déployés

`modules/home/common.nix` lie depuis `dotfiles/` : configs Doom Emacs, thèmes btop, CSS YouTube
Music, `hyprlock`, le fond d'écran (`Pictures/Wallpapers`, lu par Caelestia) et `coc.lua` pour Neovim.
Il installe aussi la commande `temp-fixes`.

La configuration de Caelestia (`~/.config/caelestia/{shell,cli}.json`) est générée par son module.

## Différences principales

| Sujet | desktop | laptop |
|---|---|---|
| Paquets spécifiques | OBS Studio (CUDA) + plugins, lazydocker | `moonlight-qt` (unstable) |
| Alias zsh | `valheim` | `ac`, `bat` |
| Signature git | non forcée | `signing.format = openpgp` |
| rofi | thème Catppuccin du dépôt | thème Stylix |
| Config YouTube Music | `config-desktop.json` | `config.json` |
