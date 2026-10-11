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
    # theme = ./rofi/catppuccin-latte.rasi;
    # font = "MesloLGS NF";
  };

  # kitty config
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    shellIntegration.enableZshIntegration = true;
    # font ={
    #  package = pkgs.meslo-lgs-nf;
    #  name = "MesloLGS NF";
    #  size = 9;
    # };
    # extraConfig = "
    # # font_family MesloLGS NF

    # # vim:ft=kitty

    # ## name:     Catppuccin Kitty Latte
    # ## author:   Catppuccin Org
    # ## license:  MIT
    # ## upstream: https://github.com/catppuccin/kitty/blob/main/themes/latte.conf
    # ## blurb:    Soothing pastel theme for the high-spirited!



    # # The basic colors
    # foreground              #4C4F69
    # background              #EFF1F5
    # selection_foreground    #EFF1F5
    # selection_background    #DC8A78

    # # Cursor colors
    # cursor                  #DC8A78
    # cursor_text_color       #EFF1F5

    # # URL underline color when hovering with mouse
    # url_color               #DC8A78

    # # Kitty window border colors
    # active_border_color     #7287FD
    # inactive_border_color   #9CA0B0
    # bell_border_color       #DF8E1D

    # # OS Window titlebar colors
    # wayland_titlebar_color system
    # macos_titlebar_color system

    # # Tab bar colors
    # active_tab_foreground   #EFF1F5
    # active_tab_background   #8839EF
    # inactive_tab_foreground #4C4F69
    # inactive_tab_background #9CA0B0
    # tab_bar_background      #BCC0CC

    # # Colors for marks (marked text in the terminal)
    # mark1_foreground #EFF1F5
    # mark1_background #7287fD
    # mark2_foreground #EFF1F5
    # mark2_background #8839EF
    # mark3_foreground #EFF1F5
    # mark3_background #209FB5

    # # The 16 terminal colors

    # # black
    # color0 #5C5F77
    # color8 #6C6F85

    # # red
    # color1 #D20F39
    # color9 #D20F39

    # # green
    # color2  #40A02B
    # color10 #40A02B

    # # yellow
    # color3  #DF8E1D
    # color11 #DF8E1D

    # # blue
    # color4  #1E66F5
    # color12 #1E66F5

    # # magenta
    # color5  #EA76CB
    # color13 #EA76CB

    # # cyan
    # color6  #179299
    # color14 #179299

    # # white
    # color7  #ACB0BE
    # color15 #BCC0CC

    # background_opacity 0.85
    # ";
  };

}
