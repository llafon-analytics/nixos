{ pkgs, lib, ... }:

let
  toml = pkgs.formats.toml { };

  # Versioned with the modules it describes; the store path changes with its content.
  cheatsheet = ./cheatsheet.md;

  # Announce the cheatsheet once per new version, through Caelestia's notification
  # server. Caelestia starts asynchronously, so notify-send is retried for a while;
  # the version is only recorded once a notification was actually delivered.
  cheatsheetNotify = pkgs.writeShellScript "cheatsheet-notify" ''
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/nixos-cheatsheet"
    seen="$state/seen"
    [ "$(cat "$seen" 2>/dev/null)" = "${cheatsheet}" ] && exit 0
    for _ in $(seq 30); do
      if ${lib.getExe' pkgs.libnotify "notify-send"} -a NixOS -i help-about \
        "Nouveautés de la configuration" \
        "SUPER + F1 : aide-mémoire (raccourcis, commandes, nouveautés)"; then
        mkdir -p "$state"
        echo "${cheatsheet}" > "$seen"
        exit 0
      fi
      sleep 1
    done
    exit 1
  '';
in
{
  # Pyprland drop-down terminal, toggled with SUPER+SHIFT+Return (hyprland.base.lua).
  # The kitty process lives on between toggles, so the shell session is kept.
  # SUPER+F1 toggles the cheatsheet the same way.
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
    scratchpads.help = {
      command = "kitty --class kitty-cheatsheet ${lib.getExe pkgs.glow} --tui --style light ${cheatsheet}";
      class = "kitty-cheatsheet";
      animation = "fromTop";
      size = "60% 80%";
      max_size = "1100px 100%";
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

  systemd.user.services.cheatsheet-notify = {
    Unit = {
      Description = "Announce a new version of the cheatsheet";
      After = [ "hyprland-session.target" "caelestia.service" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${cheatsheetNotify}";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
