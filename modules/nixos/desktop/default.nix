{ lib, ... }:

# Graphical session shared by both hosts: Hyprland with Caelestia, Plasma as a
# fallback session, PipeWire, fonts, theming and desktop services.
{
  imports = [
    ./apps.nix
    ./audio.nix
    ./fonts.nix
    ./stylix.nix
    ./xdg-portal.nix
  ];

  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  # TEMP-FIX(hypridle-forced-off): idle handling (lock + screen off) is owned by Caelestia's own idle
  # daemon (see modules/home/caelestia.nix), not hypridle. Force it off: the
  # nixpkgs hyprlock module unconditionally sets this to true.
  services.hypridle.enable = lib.mkForce false;

  environment.variables = {
    QT_QPA_PLATFORM = "wayland;xcb"; # Wayland first, X11 fallback.
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.flatpak.enable = true;
}
