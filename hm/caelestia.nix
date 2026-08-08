{ config, lib, pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # caelestia-cli ships Material-You-generated hues for "catppuccin/latte", not the
  # real Catppuccin palette (e.g. pink resolves to a saturated blue). Patch the shipped
  # data file with the canonical hex values already used elsewhere in this repo
  # (hm/hyprlock/latte.conf).
  catppuccinLattePalette = {
    rosewater = "dc8a78"; flamingo = "dd7878"; pink = "ea76cb"; mauve = "8839ef";
    red = "d20f39"; maroon = "e64553"; peach = "fe640b"; yellow = "df8e1d";
    green = "40a02b"; teal = "179299"; sky = "04a5e5"; sapphire = "209fb5";
    blue = "1e66f5"; lavender = "7287fd"; text = "4c4f69"; subtext1 = "5c5f77";
    subtext0 = "6c6f85"; overlay2 = "7c7f93"; overlay1 = "8c8fa1"; overlay0 = "9ca0b0";
    surface2 = "acb0be"; surface1 = "bcc0cc"; surface0 = "ccd0da"; base = "eff1f5";
    mantle = "e6e9ef"; crust = "dce0e8";
  };
  # As shipped upstream (light.txt), keyed by the wrong generated value being replaced.
  shippedLatteValues = {
    rosewater = "7d76b1"; flamingo = "6470bd"; pink = "057ee6"; mauve = "005791";
    red = "003ee0"; maroon = "2751f9"; peach = "8a4dff"; yellow = "008f68";
    green = "007991"; teal = "007195"; sky = "0082b6"; sapphire = "037ba6";
    blue = "005e90"; lavender = "0077b7"; text = "191c1e"; subtext1 = "41484e";
    subtext0 = "6e757c"; overlay2 = "7f858b"; overlay1 = "91979d"; overlay0 = "a4a8ae";
    surface2 = "b7babf"; surface1 = "cbced2"; surface0 = "e1e3e7"; base = "f8f9fc";
    mantle = "eff1f4"; crust = "e9ebef";
  };

  patchedCaelestiaCli =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + lib.concatStrings (lib.mapAttrsToList (name: correct: ''
        substituteInPlace src/caelestia/data/schemes/catppuccin/latte/light.txt \
          --replace-fail "${name} ${shippedLatteValues.${name}}" "${name} ${correct}"
      '') catppuccinLattePalette);
    });
in
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
      package = patchedCaelestiaCli;

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
