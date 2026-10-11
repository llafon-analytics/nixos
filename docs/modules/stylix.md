# Stylix

Stylix est injecté depuis `common-modules.nix` et configuré dans `configuration.nix`.

## Configuration active

- `stylix.enable = true`
- Le fond d'écran est géré par Caelestia, pas par Stylix.
- Schéma base16: `catppuccin-latte`
- Accent principal (`base0D`): Pink (`ea76cb`)
- Curseur: `catppuccin-latte-pink-cursors` (taille 32)
- Police principale: `JetBrainsMono NF`
- `stylix.homeManagerIntegration.followSystem = true`

## Cibles explicitement désactivées

- `stylix.targets.vscode.enable = false` dans `hm/vscode.nix` pour les deux machines.
  VS Code utilise le thème `Catppuccin Latte` fourni par l'extension Catppuccin.
- `stylix.targets.zen-browser.enable = false` dans `hm/zen-browser.nix`, au profit du
  thème Latte/Pink de l'input `catppuccin-zen`.
- `stylix.targets.rofi.enable = false` dans `wm-desktop/wm.nix`, au profit de
  `wm-desktop/rofi/catppuccin-latte.rasi`. Le laptop laisse Stylix thémer rofi.

## Caelestia

Caelestia n'a pas de cible Stylix : il utilise son propre schéma intégré
`catppuccin` / `latte` / mode `light`, épinglé par une activation Home Manager dans
`hm/caelestia.nix`. Voir [Caelestia](caelestia.md) — en particulier les
`cli.settings.theme.enable*` qui empêchent son CLI de réécrire les fichiers gérés
par Stylix.
