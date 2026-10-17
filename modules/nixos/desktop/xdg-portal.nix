{ pkgs, ... }:

{
  ##############################################################
  # XDG Desktop Portal routing for the Hyprland session
  ##############################################################
  #
  # Goal: `org.freedesktop.impl.portal.FileChooser` is served by the KDE
  # backend (the Dolphin-style dialog) for every portal-aware application,
  # while xdg-desktop-portal-hyprland keeps ScreenCast/Screenshot/
  # GlobalShortcuts and xdg-desktop-portal-gtk stays the fallback for the
  # rest.
  #
  # How the routing file is picked (xdg-desktop-portal 1.20,
  # src/xdp-portal-impl.c:load_portal_configuration): the daemon lowercases
  # every entry of $XDG_CURRENT_DESKTOP ("Hyprland" -> "hyprland") and takes
  # the FIRST directory that contains `<desktop>-portals.conf` or
  # `portals.conf`, searching in this order:
  #
  #   $XDG_CONFIG_HOME -> $XDG_CONFIG_DIRS (includes /etc/xdg) -> /etc/xdg
  #   -> $XDG_DATA_HOME -> $XDG_DATA_DIRS -> $prefix/share
  #
  # `xdg.portal.config.hyprland` writes
  # /etc/xdg/xdg-desktop-portal/hyprland-portals.conf, which therefore wins
  # over the `default=hyprland;gtk` file that the hyprland package ships in
  # $XDG_DATA_DIRS through `xdg.portal.configPackages` (set by the NixOS
  # Hyprland module). Config files are NOT merged across directories: the
  # winning file replaces the shipped one wholesale, which is why `default`
  # has to be restated below.
  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk

      # Declared explicitly instead of relying on
      # `services.desktopManager.plasma6.enable` (which also pulls it in), so
      # the FileChooser routing below stays valid if Plasma is ever dropped.
      # This installs the portal backend and its KDE Frameworks libraries
      # only; it starts no Plasma session, no kwin, and no Plasma services.
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];

    config.hyprland = {
      # Per-interface fallback list: the first backend whose .portal file
      # declares the interface wins, so the result does not depend on the
      # order in which backends happen to start.
      #   hyprland.portal -> ScreenCast, Screenshot, GlobalShortcuts
      #   gtk.portal      -> everything else it declares (Settings,
      #                      Notification, Print, AppChooser, Access,
      #                      Account, Email, Inhibit, DynamicLauncher,
      #                      Lockdown, Wallpaper)
      default = [
        "hyprland"
        "gtk"
      ];

      # The single interface routed away from the defaults above. Applies to
      # Open File / Open Multiple Files / Select Folder / Save As for every
      # client that goes through the portal (Flatpak, GTK4, Chromium and
      # Electron, Qt with the xdgdesktopportal dialogs, Zen via
      # widget.use-xdg-desktop-portal.file-picker).
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };
}
