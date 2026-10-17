{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Must be the exact same derivation the "desktop" user's caelestia.service runs
  # (home-manager.useGlobalPkgs = false means its pkgs is a separate instantiation
  # from this NixOS module's, so re-resolving `inputs.caelestia-shell.packages.*.default`
  # here would build a different store path). caelestia-shell's IPC instance lookup is
  # self-referential to its own $out/share/caelestia-shell/shell.qml, so a mismatched
  # store path means `ipc call` silently targets an instance that never runs, and
  # inhibit_idle/uninhibit_idle below fail with "No running instances for ...".
  caelestiaShell = config.home-manager.users.desktop.programs.caelestia.package;

  dockerHelper = pkgs.writeShellApplication {
    name = "gamemode-docker";
    runtimeInputs = with pkgs; [
      coreutils
      docker
      systemd
      util-linux
    ];
    text = builtins.readFile ../../../scripts/gamemode/gamemode-docker.sh;
  };

  userHelper = pkgs.writeShellApplication {
    name = "gamemode-optimizations";
    runtimeInputs = with pkgs; [
      caelestiaShell
      coreutils
      hyprland
      jq
      sudo
      systemd
      util-linux
    ];
    runtimeEnv.GAMEMODE_DOCKER_HELPER = lib.getExe dockerHelper;
    text = builtins.readFile ../../../scripts/gamemode/gamemode-optimizations.sh;
  };
in
{
  programs.gamemode.settings.custom = {
    start = "${lib.getExe userHelper} start";
    end = "${lib.getExe userHelper} end";
    script_timeout = 120;
  };

  security.sudo.extraRules = [
    {
      users = [ "desktop" ];
      commands = [
        {
          command = lib.getExe dockerHelper;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /run/gamemode-docker 0700 root root -"
  ];
}
