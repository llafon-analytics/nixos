# Stylix

Stylix is imported by `modules/nixos/default.nix` and configured in `modules/nixos/desktop/stylix.nix`.

## Active configuration

- `stylix.enable = true`
- The wallpaper is handled by Caelestia, not by Stylix.
- base16 scheme: `catppuccin-latte`
- Main accent (`base0D`): Pink (`ea76cb`)
- Cursor: `catppuccin-latte-pink-cursors` (size 32)
- Main font: `JetBrainsMono NF` (every role)
- Qt: `qtct` platform
- `stylix.homeManagerIntegration.followSystem = true`

## Explicitly disabled targets

- `stylix.targets.vscode.enable = false` in `modules/home/vscode.nix`: VS Code uses the
  `Catppuccin Latte` theme from the Catppuccin extension.
- `stylix.targets.zen-browser.enable = false` in `modules/home/zen-browser.nix`, in favour of the
  Latte/Pink theme from the `catppuccin-zen` input.
- `stylix.targets.rofi.enable = false` in `hosts/desktop/home.nix`, in favour of
  `modules/home/hyprland/catppuccin-latte.rasi`. The laptop lets Stylix theme rofi.

## KDE activation

On the desktop, Stylix's KDE "look-and-feel" activation is skipped at boot: it needs a running
Plasma session and cost ~0.8 s on the critical path. The autostart entry still applies the theme
in Plasma. Temporary fix `stylix-kde-activation`.

## Caelestia

Caelestia has no Stylix target: it uses its own built-in `catppuccin` / `latte` / `light`
scheme, pinned by a Home Manager activation in `modules/home/caelestia.nix`. See
[Caelestia](caelestia.md), in particular the `cli.settings.theme.enable*` settings that stop its
CLI from rewriting files managed by Stylix.
