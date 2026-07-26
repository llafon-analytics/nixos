# Stylix

Stylix is enabled from `common-modules.nix` and configured in `configuration.nix`:

- wallpaper is managed by `awww`, not Stylix
- Catppuccin Latte base16 scheme
- Pink (`ea76cb`) primary accent through the `base0D` override
- `catppuccin-latte-pink-cursors` at size 32
- `JetBrainsMono NF` font customization

## Explicitly disabled target

- `stylix.targets.vscode.enable = false` in `hm/vscode.nix` for both hosts.
- VS Code uses the `Catppuccin Latte` theme provided by the Catppuccin extension.
