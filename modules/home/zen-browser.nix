{
  config,
  inputs,
  lib,
  ...
}:

let
  cfg = config.local.zenBrowser;
  zenRoot = "${config.home.homeDirectory}/${cfg.configRoot}";
  themeRoot = inputs.catppuccin-zen + "/themes/Latte/Pink";
  userChrome = builtins.readFile "${themeRoot}/userChrome.css";
  userContent = builtins.readFile "${themeRoot}/userContent.css";
in
{
  options.local.zenBrowser = {
    configRoot = lib.mkOption {
      type = lib.types.str;
      default = ".config/zen";
      description = "Zen configuration directory, relative to the home directory.";
    };

    profilePath = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Existing or predictable Zen profile directory name.";
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Zen profile display name.";
    };
  };

  config = {
    # Zen has its own Latte/Pink theme; keep the global Stylix palette out of it.
    stylix.targets.zen-browser.enable = false;

    programs.zen-browser = {
      enable = true;

      # Override the module's XDG defaults when a host still uses Zen's legacy
      # ~/.zen profile root. This keeps profiles.ini and all browser data in place.
      configPath = zenRoot;
      profilesPath = zenRoot;

      profiles.default = {
        id = 0;
        name = cfg.profileName;
        path = cfg.profilePath;
        isDefault = true;
        # Read directly from the locked input. The module writes this content to
        # the profile through its native userChrome/userContent options.
        userChrome = userChrome;
        userContent = userContent;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Firefox/Zen: 0 = dark, 1 = light, 2 = system, 3 = browser theme.
          "layout.css.prefers-color-scheme.content-override" = 1;
          # 0 = never, 1 = always, 2 = auto (the built-in default). "auto"
          # resolves to `IsRunningUnderFlatpakOrSnap() || GTK_USE_PORTAL`
          # (gecko widget/gtk/WidgetUtilsGtk.cpp, ShouldUsePortal), so a native
          # non-sandboxed build like this one never reaches the portal on its
          # own. Forcing 1 opts Zen into the session's portal FileChooser; which
          # backend answers is decided globally in modules/xdg-portal.nix, not
          # here.
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };

    home.file."${zenRoot}/${cfg.profilePath}/chrome/zen-logo-latte.svg".source =
      themeRoot + "/zen-logo-latte.svg";
  };
}
