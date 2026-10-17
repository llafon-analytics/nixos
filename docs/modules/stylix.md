# Stylix

Stylix est importé par `modules/nixos/default.nix` et configuré dans `modules/nixos/desktop/stylix.nix`.

## Configuration active

- `stylix.enable = true`
- Le fond d'écran est géré par Caelestia, pas par Stylix.
- Schéma base16 : `catppuccin-latte`
- Accent principal (`base0D`) : Pink (`ea76cb`)
- Curseur : `catppuccin-latte-pink-cursors` (taille 32)
- Police principale : `JetBrainsMono NF` (tous les rôles)
- Qt : plateforme `qtct`
- `stylix.homeManagerIntegration.followSystem = true`

## Cibles explicitement désactivées

- `stylix.targets.vscode.enable = false` dans `modules/home/vscode.nix` : VS Code utilise le thème
  `Catppuccin Latte` de l'extension Catppuccin.
- `stylix.targets.zen-browser.enable = false` dans `modules/home/zen-browser.nix`, au profit du
  thème Latte/Pink de l'input `catppuccin-zen`.
- `stylix.targets.rofi.enable = false` dans `hosts/desktop/home.nix`, au profit de
  `modules/home/hyprland/catppuccin-latte.rasi`. Le laptop laisse Stylix thémer rofi.

## Activation KDE

Sur le desktop, l'activation « look-and-feel » KDE de Stylix est neutralisée au démarrage : elle a
besoin d'une session Plasma et coûtait ~0,8 s sur le chemin critique. L'entrée autostart applique
quand même le thème dans Plasma. Fix temporaire `stylix-kde-activation`.

## Caelestia

Caelestia n'a pas de cible Stylix : il utilise son propre schéma intégré
`catppuccin` / `latte` / mode `light`, épinglé par une activation Home Manager dans
`modules/home/caelestia.nix`. Voir [Caelestia](caelestia.md) — en particulier les
`cli.settings.theme.enable*` qui empêchent son CLI de réécrire les fichiers gérés
par Stylix.
