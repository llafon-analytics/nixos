# Home Manager

## Entrées par host

- `home-desktop.nix`
- `home-laptop.nix`

## Modules partagés importés

- `hm/caelestia.nix`
- `hm/vscode.nix`
- `hm/zsh.nix`
- `hm/cli-tools.nix` (Atuin, zoxide, Lazygit, nh)
- `hm/pyprland.nix` (terminal escamotable)
- `hm/neovim.nix`
- un module WM (`wm-desktop/wm.nix` ou `wm-laptop/wm.nix`)

Le module Home Manager amont de Caelestia est injecté globalement via
`home-manager.sharedModules` dans `common-modules.nix`.

## Fichiers déployés

Les deux profils déploient notamment:

- configs Doom Emacs
- configs btop
- configs YouTube Music
- `hypridle.conf` et `hyprlock`
- le fond d'écran dans `Pictures/Wallpapers` (lu par Caelestia)

La configuration de Caelestia (`~/.config/caelestia/{shell,cli}.json`) est générée
par son module, pas déployée par `home.file`.

## Différences principales

| Sujet | desktop | laptop |
|---|---|---|
| Package utilisateur spécifique | - | `moonlight-qt` |
| Alias zsh host | `valheim` | `ac`, `bat` |
| Signature git | non forcée | `signing.format = openpgp` |
