{
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  ...
}:

# System-wide packages shared by both hosts, grouped by domain.
# Policy: `pkgs` (stable) by default; `pkgs-unstable` only for named exceptions.
let
  system = pkgs.stdenv.hostPlatform.system;

  discordNvenc = pkgs.callPackage ../../../pkgs/discord-nvenc/package.nix {
    discord = pkgs-unstable.discord.override { withVencord = true; };
    installDir = "Discord";
    bins = [
      "Discord"
      "discord"
    ];
  };
  discordCanaryNvenc = pkgs.callPackage ../../../pkgs/discord-nvenc/package.nix {
    discord = pkgs-unstable.discord-canary.override { withVencord = true; };
    installDir = "DiscordCanary";
    bins = [
      "DiscordCanary"
      "discordcanary"
    ];
  };

  groups = {
    development = with pkgs; [
      git
      gh
      inputs.codex-cli-nix.packages.${system}.default
      inputs.claude-code-nix.packages.${system}.default
      nodejs
      jq
      icu
      clang
      emacs
      postman
      docker-compose
      conda
      uv
    ];

    terminal = with pkgs; [
      kitty
      coreutils
      ripgrep
      fd
      libvterm
      fastfetch
      w3m
      unixtools.xxd
      steam-run # Run programs in an FHS environment
    ];

    system = with pkgs; [
      usbutils
      usb-modeswitch
      btop
      lm_sensors
      mission-center
      s-tui
      stress
      gnome-disk-utility
      gdu
      xdg-utils
      wirelesstools
      wavemon
      speedtest-go
    ];

    internet = with pkgs; [
      ungoogled-chromium
      # TEMP-FIX(thunderbird-onnx-cpu): keep Thunderbird's ONNX dependency CPU-only even when CUDA is enabled globally.
      (wrapThunderbird (thunderbird-unwrapped.override {
        onnxruntime = onnxruntime.override { cudaSupport = false; };
      }) { })
      discordNvenc
      discordCanaryNvenc
      proton-vpn
      proton-pass
      nzbget
      motrix
      wget
    ];

    office = with pkgs; [
      onlyoffice-desktopeditors
      zathura
      texliveFull
      poppler-utils
      freetype
      fontconfig
      glow # Terminal Markdown reader
      pandoc
      ispell
      qalculate-gtk
      parsify
      speedcrunch
      ledger
    ];

    multimedia = with pkgs; [
      (pkgs.callPackage ../../../pkgs/opennow/package.nix { }) # GeForce NOW client
      mpv
      yt-dlp
      audacity
      moc
      libmpg123
      pamixer
      pavucontrol
      easyeffects
      qpwgraph
      gimp-with-plugins
      upscayl
      feh
      v4l-utils
      ffmpeg_6
      ffmpegthumbnailer
    ];

    android = with pkgs; [
      android-tools
      scrcpy
      droidcam
    ];

    # Wayland session helpers: clipboard, screenshots, brightness, X11 tools.
    desktop = with pkgs; [
      cliphist
      wl-clipboard
      xclip
      clipse
      hyprshot
      hyprpicker
      grim
      slurp
      satty
      swaybg
      ksnip
      wluma
      brightnessctl
      xdotool
      xprop
      xwininfo
      yad
      (catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "latte";
      })
    ];

    archives = with pkgs; [
      zip
      unzip
      _7zz
      _7zz-rar
      unrar
      atool
    ];

    virtualisation = with pkgs; [ qemu ];

    fun = with pkgs; [
      pipes
      cbonsai
      cmatrix
      cava
    ];

    # Exceptions: not available in stable.
    unstable = with pkgs-unstable; [
      crosspipe # TEMP-FIX(crosspipe-unstable): graphical audio routing tool
    ];
  };
in
{
  environment.systemPackages = lib.concatLists (lib.attrValues groups);
}
