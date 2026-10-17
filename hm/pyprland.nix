{ config, pkgs, lib, ... }:

let
  toml = pkgs.formats.toml { };

  repoDir = "${config.home.homeDirectory}/Documents/nix-configuration";
  docsPort = "8765";
  chromium = lib.getExe pkgs.ungoogled-chromium;
  notify = lib.getExe' pkgs.libnotify "notify-send";

  # Documentation scratchpad: MkDocs (live reload) on loopback, shown in a dedicated
  # Chromium app window. The server lives exactly as long as that window: pypr starts
  # this script once (lazy) and closing the window stops mkdocs. flock keeps a second
  # invocation from spawning a second server.
  docsScratchpad = pkgs.writeShellScript "docs-scratchpad" ''
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/pypr-docs"
    mkdir -p "$state"
    exec 9> "$state/lock"
    ${lib.getExe' pkgs.util-linux "flock"} -n 9 || exit 0

    fail() {
      ${notify} -a NixOS -u critical -i dialog-error "Documentation" "$1 (journalctl --user -u pyprland)"
      echo "docs-scratchpad: $1" >&2
      exit 1
    }
    up() { (exec 3<>/dev/tcp/127.0.0.1/${docsPort}) 2>/dev/null; }

    [ -f "${repoDir}/mkdocs.yml" ] || fail "mkdocs.yml introuvable dans ${repoDir}"
    cd "${repoDir}"
    ${import ./mkdocs-env.nix pkgs}/bin/mkdocs serve -a 127.0.0.1:${docsPort} > "$state/mkdocs.log" 2>&1 &
    server=$!
    trap 'kill "$server" 2>/dev/null' EXIT

    for _ in $(seq 60); do
      kill -0 "$server" 2>/dev/null || fail "mkdocs s'est arrêté au démarrage ($state/mkdocs.log)"
      up && break
      sleep 0.5
    done
    up || fail "mkdocs ne répond pas sur le port ${docsPort}"

    ${chromium} --ozone-platform=wayland --user-data-dir="$state/chromium" \
      --app=http://127.0.0.1:${docsPort}
  '';

  # nixpkgs has no Linux ChatGPT app (the `chatgpt` attribute is the macOS .dmg), so
  # the web app runs in its own Chromium profile: cookies and session survive
  # hiding the window and restarts.
  chatgptApp = pkgs.writeShellScript "chatgpt-app" ''
    exec ${chromium} --ozone-platform=wayland \
      --user-data-dir="''${XDG_STATE_HOME:-$HOME/.local/state}/pypr-chatgpt" \
      --app=https://chatgpt.com
  '';

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
        "SUPER + ALT + & : aide-mémoire · nouveaux : ALT+é documentation, SUPER+C ChatGPT"; then
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
  # SUPER+ALT+& toggles the cheatsheet the same way, SUPER+ALT+é the MkDocs documentation
  # and SUPER+C ChatGPT.
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
      # The short sleep matters: glow started straight from kitty renders a blank page.
      command = "kitty --class kitty-cheatsheet sh -c 'sleep 0.3; exec ${lib.getExe pkgs.glow} --tui --style light ${cheatsheet}'";
      class = "kitty-cheatsheet";
      animation = "fromTop";
      size = "60% 80%";
      max_size = "1100px 100%";
      lazy = true;
    };
    # Chromium apps share one process per profile, so windows are matched by class
    # instead of PID (process_tracking = false also forces lazy). In --app mode Chromium
    # ignores --class and derives the app_id from the URL: chrome-<host>__<path>-<profile>.
    scratchpads.docs = {
      command = "${docsScratchpad}";
      class = "chrome-127.0.0.1__-Default";
      match_by = "class";
      process_tracking = false;
      animation = "fromTop";
      size = "70% 85%";
      max_size = "1600px 100%";
    };
    scratchpads.chatgpt = {
      command = "${chatgptApp}";
      class = "chrome-chatgpt.com__-Default";
      match_by = "class";
      process_tracking = false;
      animation = "fromTop";
      size = "50% 85%";
      max_size = "1100px 100%";
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
