# Stylix

Stylix is enabled from `common-modules.nix` and configured in `configuration.nix`:

- wallpaper is managed by Caelestia, not Stylix
- Catppuccin Latte base16 scheme
- Pink (`ea76cb`) primary accent through the `base0D` override
- `catppuccin-latte-pink-cursors` at size 32
- `JetBrainsMono NF` font customization

## Explicitly disabled targets

- `stylix.targets.vscode.enable = false` in `hm/vscode.nix` for both hosts.
  VS Code uses the `Catppuccin Latte` theme provided by the Catppuccin extension.
- `stylix.targets.zen-browser.enable = false` in `hm/zen-browser.nix`, in favour of the
  Latte/Pink theme from the `catppuccin-zen` input.
- `stylix.targets.rofi.enable = false` in `wm-desktop/wm.nix`, in favour of
  `wm-desktop/rofi/catppuccin-latte.rasi`. The laptop lets Stylix theme rofi.

## Caelestia

Caelestia has no Stylix target: it uses its own built-in `catppuccin` / `latte` /
`light` scheme, pinned by a Home Manager activation entry in `hm/caelestia.nix`. See
[Caelestia](caelestia.md) — in particular the `cli.settings.theme.enable*` flags that
stop its CLI from rewriting Stylix-managed files.
