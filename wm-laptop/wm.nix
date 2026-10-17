{ config, pkgs, ... }:

{
  # Hyprland Config
  wayland.windowManager.hyprland = {
    enable = true;
    # NixOS owns the complete Hyprland/GTK/KDE portal set. Installing only
    # Hyprland here would mask the system backend descriptors in XDG_DATA_DIRS.
    portalPackage = null;
    configType = "lua";
    extraConfig = ''
      require("base")
      require("host")
    '';
  };
  xdg.configFile = {
    "hypr/base.lua".source = ../hyprland.base.lua;
    "hypr/host.lua".source = ./hyprland.lua;
  };

  # Rofi Config
  # Caelestia's launcher replaced `-show drun` (SUPER+space); rofi is kept only as
  # a window switcher (SUPER+W), which Caelestia has no equivalent for.
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "window";
      icon-theme = "Oranchelo";
      show-icons = true;
      terminal = "kitty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };
  };

  # kitty config
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableZshIntegration = true;
    # Kitty otherwise reopens in the last saved window state (~/.cache/kitty/main.json); once
    # that is "maximized", Hyprland shows every new terminal fullscreen.
    settings.remember_window_size = false;
  };
}
