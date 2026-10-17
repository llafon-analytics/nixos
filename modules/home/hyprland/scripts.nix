{ pkgs, ... }:

# Helper scripts bound in hyprland.base.lua, installed as commands so the
# binds do not depend on where this repository is checked out.
let
  muteDiscord = pkgs.writeShellApplication {
    name = "mute-discord";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnugrep
      hyprland
      jq
      pipewire
      procps
      wireplumber
    ];
    # The script handles its own errors; only `set -u` as in the original.
    bashOptions = [ "nounset" ];
    text = builtins.readFile ../../../scripts/mute-discord.sh;
  };

  sattyShot = pkgs.writeShellApplication {
    name = "satty-shot";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      hyprpicker
      satty
      slurp
    ];
    text = builtins.readFile ../../../scripts/satty-shot.sh;
  };
in
{
  home.packages = [
    muteDiscord
    sattyShot
  ];
}
