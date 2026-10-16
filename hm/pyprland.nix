{ pkgs, ... }:

let
  toml = pkgs.formats.toml { };
in
{
  # Pyprland drop-down terminal, toggled with SUPER+SHIFT+Return (hyprland.base.lua).
  # The kitty process lives on between toggles, so the shell session is kept.
  home.packages = [ pkgs.pyprland ];

  xdg.configFile."pypr/config.toml".source = toml.generate "pyprland-config.toml" {
    pyprland.plugins = [ "scratchpads" ];
    scratchpads.term = {
      command = "kitty --class kitty-dropterm";
      class = "kitty-dropterm";
      animation = "fromTop";
      size = "75% 60%";
      max_size = "1920px 100%";
      lazy = true;
    };
  };

  # Same model as Caelestia: a user service tied to the session, but bound to
  # hyprland-session.target so it never starts under Plasma.
  systemd.user.services.pyprland = {
    Unit = {
      Description = "Pyprland daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.pyprland}/bin/pypr";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
