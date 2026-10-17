{ pkgs, lib, ... }:

{
  imports = [ ../../modules/home/common.nix ];

  home.username = "desktop";
  home.homeDirectory = "/home/desktop";

  # TEMP-FIX(stylix-kde-activation): Stylix's KDE activation needs a running Plasma session, so at boot it only
  # fails (xcb_connect) after ~0.8s on the critical path. The autostart entry
  # still applies the theme when a Plasma session starts.
  home.activation.stylixLookAndFeel = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] "");

  home.file.".config/YouTube Music/config.json".source =
    ../../dotfiles/youtube-music/config-desktop.json;
  xdg.configFile."hypr/host.lua".source = ./hyprland.lua;

  local.zenBrowser = {
    # Preserve the existing default profile and its historical ~/.zen location.
    configRoot = ".zen";
    profilePath = "9ra76qx0.Default Profile";
    profileName = "Default Profile";
  };

  # Catppuccin rofi theme instead of the Stylix one.
  stylix.targets.rofi.enable = false;
  programs.rofi = {
    theme = ../../modules/home/hyprland/catppuccin-latte.rasi;
    font = "JetBrainsMono NF";
  };

  programs.kitty.font = {
    name = lib.mkForce "JetBrainsMono NF";
    size = lib.mkForce 13;
  };

  # Docker only runs on the desktop.
  programs.lazydocker.enable = true;

  programs.zsh.shellAliases = {
    valheim = "cd /home/desktop/.steam/steam/steamapps/common/Valheim/ && gamemoderun mangohud steam-run /home/desktop/.steam/steam/steamapps/common/Valheim/start_game_bepinex.sh";
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      wlrobs
      obs-vaapi
      obs-pipewire-audio-capture
      obs-livesplit-one
      obs-gstreamer
      # TEMP-FIX(obs-backgroundremoval-cpu): CPU-only inference, as before useGlobalPkgs.
      (obs-backgroundremoval.override {
        onnxruntime = pkgs.onnxruntime.override { cudaSupport = false; };
        opencv = pkgs.opencv.override { enableCuda = false; };
      })
      input-overlay
      obs-shaderfilter
    ];
  };
}
