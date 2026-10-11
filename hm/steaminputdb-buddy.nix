{ pkgs, lib, ... }:
let
  steaminputdb-buddy = pkgs.callPackage ../packages/steaminputdb-buddy.nix { };
in
{
  # Steam only exposes the CEF remote-debugging port (used by the Buddy app
  # to inject the SteamInputDB UI into the client) when this marker file is
  # present in the Steam directory. Only touch it if Steam has already run
  # at least once (i.e. ~/.steam/steam exists) so this never races with, or
  # clobbers, the ~/.steam/steam symlink that Steam itself creates on first
  # launch.
  home.activation.steaminputdbBuddyCefDebug = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    steam_dir="$HOME/.steam/steam"
    marker="$steam_dir/.cef-enable-remote-debugging"
    if [ -d "$steam_dir" ] && [ ! -e "$marker" ]; then
      run touch "$marker"
    fi
  '';

  systemd.user.services.steaminputdb-buddy = {
    Unit = {
      Description = "SteamInputDB Buddy";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${steaminputdb-buddy}/bin/steaminputdb-buddy run --tray-display";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
