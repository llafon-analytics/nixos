{ config, lib, ... }:

{
  # Caelestia Shell — replaces hyprpanel (unmaintained).
  # Bar, notifications, launcher, lockscreen and wallpaper all live here.
  programs.caelestia = {
    enable = true;

    # Started by graphical-session.target, so no exec-once in hyprland.base.lua.
    systemd.enable = true;

    settings = {
      paths.wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
    };

    cli = {
      # Required for `caelestia shell ...`, scheme, wallpaper and lock.
      enable = true;

      # Stylix owns the system theme. Left at their defaults the CLI rewrites
      # gtk.css, the Hyprland colours, btop.conf and terminal sequences on every
      # scheme change, which collides with Stylix's read-only symlinks.
      settings.theme = {
        enableTerm = false;
        enableHypr = false;
        enableDiscord = false;
        enableSpicetify = false;
        enablePandora = false;
        enableFuzzel = false;
        enableBtop = false;
        enableNvtop = false;
        enableHtop = false;
        enableGtk = false;
        enableQt = false;
        enableWarp = false;
        enableChromium = false;
        enableZed = false;
        enableCava = false;
      };
    };
  };

  # Pin Caelestia's colour scheme to Catppuccin Latte, matching Stylix.
  # The scheme is runtime state (~/.local/state/caelestia/scheme.json) whose colour
  # values are computed by the CLI, so we re-apply it rather than writing it by hand.
  # Latte only ships a light mode. A failure here must not break nixos-rebuild.
  home.activation.caelestiaScheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run --quiet ${config.programs.caelestia.cli.package}/bin/caelestia \
      scheme set -n catppuccin -f latte -m light || true
  '';
}
