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

  # Independent of the named-colour fix above: the shipped light.txt also carries the
  # Material 3 semantic roles (primary/secondary/tertiary + on*/*Container/*Fixed*)
  # that actually drive Caelestia's accent (buttons, highlights, focus). Upstream
  # derives these from a blue seed. Retint them to Catppuccin Latte pink (ea76cb) by
  # running caelestia-cli's own generator (caelestia.utils.material.generator.gen_scheme,
  # the same code path used for dynamic wallpaper-based schemes) with source colour
  # ea76cb, mode=light, flavour=latte, variant=tonalspot (Caelestia's default).
  catppuccinLattePinkAccent = {
    primary_paletteKeyColor = "9b678a"; secondary_paletteKeyColor = "8a7080";
    tertiary_paletteKeyColor = "846e99"; surfaceTint = "814f71";
    primary = "814f71"; onPrimary = "fff7f9"; primaryContainer = "febfe7";
    onPrimaryContainer = "663858"; inversePrimary = "febfe7";
    secondary = "705867"; onSecondary = "fff7f9"; secondaryContainer = "fadaec";
    onSecondaryContainer = "624b59";
    tertiary = "6b5780"; onTertiary = "fff6ff"; tertiaryContainer = "e1c8f8";
    onTertiaryContainer = "533f66";
    primaryFixed = "febfe7"; primaryFixedDim = "efb2d9";
    onPrimaryFixed = "502544"; onPrimaryFixedVariant = "704162";
    secondaryFixed = "fadaec"; secondaryFixedDim = "ebccdd";
    onSecondaryFixed = "4f3947"; onSecondaryFixedVariant = "6d5463";
    tertiaryFixed = "e1c8f8"; tertiaryFixedDim = "d3bae9";
    onTertiaryFixed = "3f2c52"; onTertiaryFixedVariant = "5c4870";
  };
  # As shipped upstream (light.txt), keyed by the wrong blue-derived value being replaced.
  shippedLatteAccentValues = {
    primary_paletteKeyColor = "417da2"; secondary_paletteKeyColor = "657a8a";
    tertiary_paletteKeyColor = "92689d"; surfaceTint = "236488";
    primary = "3e7b9f"; onPrimary = "ffffff"; primaryContainer = "417da2";
    onPrimaryContainer = "00060c"; inversePrimary = "93cdf6";
    secondary = "4c6170"; onSecondary = "ffffff"; secondaryContainer = "cfe5f8";
    onSecondaryContainer = "526776";
    tertiary = "8f659a"; onTertiary = "ffffff"; tertiaryContainer = "8f659a";
    onTertiaryContainer = "ffffff";
    primaryFixed = "c7e7ff"; primaryFixedDim = "93cdf6";
    onPrimaryFixed = "001e2e"; onPrimaryFixedVariant = "004c6d";
    secondaryFixed = "cfe5f8"; secondaryFixedDim = "b4c9db";
    onSecondaryFixed = "071e2b"; onSecondaryFixedVariant = "354958";
    tertiaryFixed = "fad7ff"; tertiaryFixedDim = "e6b6f1";
    onTertiaryFixed = "2e0a3b"; onTertiaryFixedVariant = "5e3869";
  };

  patchedCaelestiaCli =
    inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default.overrideAttrs (old: {
      # Upstream sets `patchPhase` itself (a full phase override, not `patches`/`postPatch`),
      # so genericBuild evals that string directly and never sources `postPatch` — appending
      # there is a silent no-op. Append to `patchPhase` instead so our substitutions actually
      # run. (Verified by building and inspecting the output wheel: without this, none of the
      # substituteInPlace calls below land in the built package.)
      patchPhase = old.patchPhase + lib.concatStrings (lib.mapAttrsToList (name: correct: ''
        substituteInPlace src/caelestia/data/schemes/catppuccin/latte/light.txt \
          --replace-fail "${name} ${shippedLatteValues.${name}}" "${name} ${correct}"
      '') catppuccinLattePalette) + lib.concatStrings (lib.mapAttrsToList (name: correct: ''
        substituteInPlace src/caelestia/data/schemes/catppuccin/latte/light.txt \
          --replace-fail "${name} ${shippedLatteAccentValues.${name}}" "${name} ${correct}"
      '') catppuccinLattePinkAccent);
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
      launcher.actionPrefix = "/";
      services.useFahrenheit = false;

      # Keep the bar controls aligned with the selected Nexus settings.  The
      # laptop keeps its hardware-specific indicators while the desktop bar
      # stays focused on the shared controls.
      bar = {
        activeWindow = {
          compact = false;
          inverted = false;
          showOnHover = false;
        };
        popouts = {
          activeWindow = true;
          tray = true;
          statusIcons = true;
        };
        tray = {
          background = false;
          recolour = true;
          compact = false;
        };
        statusIcons = [
          { id = "lockStatus"; enabled = true; }
          { id = "audio"; enabled = true; }
          { id = "microphone"; enabled = true; }
          { id = "kbLayout"; enabled = false; }
          { id = "network"; enabled = true; }
        ] ++ lib.optionals (config.home.username == "laptop") [
          { id = "bluetooth"; enabled = true; }
          { id = "battery"; enabled = true; }
        ];
      };

      # Upstream's default terminal command isn't installed here, so CLI apps
      # launched from the launcher silently fail to spawn. Force kitty.
      general.apps.terminal = [ "kitty" "-e" ];

      # Caelestia's own idle daemon (IdleMonitors.qml) is now the single
      # source of truth for idle behaviour (hypridle is disabled, see
      # configuration.nix). Set the full timeout list explicitly: it
      # replaces upstream's default list, which ends in suspend/hibernate,
      # so idle only ever locks — screens are never blanked or put to sleep.
      # `timeout` is in seconds (Quickshell's IdleMonitor, not milliseconds).
      general.idle = {
        lockBeforeSleep = true;
        timeouts = [
          { timeout = 300; idleAction = "lock"; }
        ];
      };
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
  #
  # `caelestia scheme set` is a no-op if name/flavour/mode already match the current
  # state file (each setter early-returns on an unchanged value, so the colours are
  # never re-read from the data file). That means a package update that only changes
  # the underlying hex values (e.g. re-patching light.txt) would never be picked up
  # while already running catppuccin/latte/light. Delete the state file first so it's
  # always regenerated from the current (patched) data on every activation.
  home.activation.caelestiaScheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "${config.home.homeDirectory}/.local/state/caelestia/scheme.json"
    run --quiet ${config.programs.caelestia.cli.package}/bin/caelestia \
      scheme set -n catppuccin -f latte -m light || true
  '';
}
