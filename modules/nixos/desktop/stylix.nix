{
  config,
  lib,
  pkgs,
  ...
}:

{
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
  stylix.override.base0D = "ea76cb";
  stylix.homeManagerIntegration.followSystem = true;
  stylix.targets.qt.platform = lib.mkForce "qtct";
  stylix.cursor.package = pkgs.catppuccin-cursors.lattePink;
  stylix.cursor.name = "catppuccin-latte-pink-cursors";
  stylix.cursor.size = 32;
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono NF";
    };
    # The monospace font is used for every role.
    serif = config.stylix.fonts.monospace;
    sansSerif = config.stylix.fonts.monospace;
    emoji = config.stylix.fonts.monospace;
  };
}
