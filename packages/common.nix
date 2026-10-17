{ config, pkgs, pkgs-unstable, lib, inputs, ... }:

let
  openNow = pkgs.callPackage ./opennow.nix { };

  discordBase = pkgs-unstable.discord.override {
    withVencord = true;
  };

  discordCanaryBase = pkgs-unstable.discord-canary.override {
    withVencord = true;
  };

  discordNvencPatchScript = pkgs.writeText "discord-nvenc-patch.py" ''
import sys
from pathlib import Path

voice_index = Path(sys.argv[1])
text = voice_index.read_text()

def replace_once(old, new):
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one match, found {count}: {old[:120]!r}")
    text = text.replace(old, new, 1)

replace_once(
    "        setTransportOptions: (options) => instance.setTransportOptions(options),",
    """        setTransportOptions: (options) => {
          let patchedOptions = options;
          if (process.platform === 'linux'
              && options != null
              && typeof options === 'object'
              && typeof options.videoEncoderExperiments === 'string') {
              const values = [];
              const seen = new Set();
              for (const part of options.videoEncoderExperiments.split(',')) {
                  const token = part.trim();
                  if (!token || token === 'vaapi' || seen.has(token)) {
                      continue;
                  }
                  values.push(token);
                  seen.add(token);
              }
              for (const token of ['linux-nvenc', 'useCaptureDeviceForEncode']) {
                  if (seen.has(token)) {
                      continue;
                  }
                  values.push(token);
                  seen.add(token);
              }
              const nextVideoEncoderExperiments = values.join(',');
              if (nextVideoEncoderExperiments !== options.videoEncoderExperiments) {
                  patchedOptions = {
                      ...options,
                      videoEncoderExperiments: nextVideoEncoderExperiments,
                  };
              }
          }
          return instance.setTransportOptions(patchedOptions);
      },""",
)

replace_once(
    "        setDesktopSourceWithOptions: (options) => instance.setDesktopSourceWithOptions(options),",
    """        setDesktopSourceWithOptions: (options) => {
          let patchedOptions = options;
          if (process.platform === 'linux'
              && options != null
              && typeof options === 'object'
              && options.useCaptureDeviceForEncode !== true) {
              patchedOptions = {
                  ...options,
                  useCaptureDeviceForEncode: true,
              };
          }
          return instance.setDesktopSourceWithOptions(patchedOptions);
      },""",
)

replace_once(
    """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    const instance = new VoiceEngine.VoiceConnection(userId, connectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
    """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    let patchedConnectionOptions = connectionOptions;
    if (process.platform === 'linux' && connectionOptions != null && typeof connectionOptions === 'object') {
        const experiments = Array.isArray(connectionOptions.experiments) ? [...connectionOptions.experiments] : [];
        if (!experiments.includes('linux-vulkan')) {
            experiments.push('linux-vulkan');
            patchedConnectionOptions = {
                ...connectionOptions,
                experiments,
            };
        }
    }
    const instance = new VoiceEngine.VoiceConnection(userId, patchedConnectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
)

voice_index.write_text(text)
  '';

  mkDiscordNvenc = { package, installDir, bins }:
    let
      patched = package.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          voice_dir="$out/opt/${installDir}/modules/discord_voice"
          voice_index="$voice_dir/index.js"

          chmod u+w "$voice_index"
          ${pkgs.python3}/bin/python3 ${discordNvencPatchScript} "$voice_index"
          chmod +x "$voice_dir/gpu_encoder_helper" "$voice_dir/discord_voice.node"
        '';
      });
    in
    pkgs.symlinkJoin {
      name = "${patched.pname or "discord"}-nvenc-${patched.version or "wrapped"}";
      paths = [ patched ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for bin in ${lib.concatStringsSep " " bins}; do
          if [ -e "$out/bin/$bin" ]; then
            # Chromium's VAAPI decode (nvidia-vaapi-driver) makes received streams judder;
            # NVENC encoding lives in discord_voice and is unaffected.
            wrapProgram "$out/bin/$bin" \
              --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
              --add-flags "--disable-accelerated-video-decode"
          fi
        done
      '';
    };

  discordNvenc = mkDiscordNvenc {
    package = discordBase;
    installDir = "Discord";
    bins = [ "Discord" "discord" ];
  };

  discordCanaryNvenc = mkDiscordNvenc {
    package = discordCanaryBase;
    installDir = "DiscordCanary";
    bins = [ "DiscordCanary" "discordcanary" ];
  };

  # The layer is injected into every Vulkan process; linking libstdc++ statically avoids
  # "GLIBCXX_3.4.35 not found" when the host process already loaded an older libstdc++.
  lsfgVkStatic = pkgs-unstable.lsfg-vk.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DCMAKE_SHARED_LINKER_FLAGS=-static-libstdc++ -static-libgcc"
    ];
  });

  # Policy: pkgs is stable by default. Only explicitly selected fast-moving gaming packages use unstable.
  unstableGamingPkgs = with pkgs-unstable; [
    winetricks # Helper to run Windows applications via Wine
    dosbox-staging # DOS emulator for legacy software
    wineWow64Packages.waylandFull # Wine package optimized for Wayland
    radeontop # Monitor Radeon GPU usage in real time
    gamescope # Compositor for game streaming and recording
    prismlauncher # Game launcher for Linux
    mangohud # On-screen display for monitoring game performance
    heroic # Alternative game launcher (for Epic Games, etc.)
    protonup-qt # GUI tool to update Proton versions
    protontricks # Utility for managing Proton tweaks
    gwe
    lsfgVkStatic
    lsfg-vk-ui
    steamtinkerlaunch # Tool to tweak Steam launch options
  ];

  # Compatibility exceptions: these packages are not currently available in stable.
  unstableCompatibilityPkgs = with pkgs-unstable; [
    crosspipe # Graphical audio routing tool
  ];

  # 2.0: To categorize
  pkgs2_0 = with pkgs; [
    nodejs
    jq
    icu
    audacity # Audio editor for recording and editing
    moc # Console audio player
    proton-vpn # Graphical ProtonVPN client
    proton-pass
    gimp-with-plugins # Image editing software with additional plugins
    usbutils
    lutris # Gaming platform for Linux games
  ];

  # 2.1: General Productivity & Multimedia Tools
  pkgs2_1 = with pkgs; [
    onlyoffice-desktopeditors # Office suite for document editing
    feh # Lightweight image viewer and wallpaper setter
    libmpg123 # MP3 decoding library
    pipes # Fun terminal pipe animations
    cbonsai # Bonsai tree generator for the terminal
    cmatrix # Matrix-style screensaver for the terminal
    cava # Audio visualizer for the terminal
    qpwgraph # Graphing tool (verify details online if needed)
    speedtest-go # Command-line internet speed test
    android-tools # Tools for interacting with Android devices
    scrcpy # Screen mirroring tool for Android
  ];

  # 2.2: Themes & Appearance Customizations
  pkgs2_2 = with pkgs; [
    # Catppuccin GTK theme with custom settings.
    (catppuccin-gtk.override {
      accents = [ "pink" ];
      size = "compact";
      tweaks = [ "rimless" ];
      variant = "latte";
    })
  ];

  # 2.3: Clipboard Management & Spell Checking
  pkgs2_3 = with pkgs; [
    cliphist # Clipboard history manager
    wl-clipboard # Wayland clipboard utility
    xclip # X11 clipboard tool for copying/pasting
    clipse # Alternative clipboard utility (check online for specifics)
    ispell # Spell-checking tool
  ];

  # 2.4: API Testing and Development Utilities
  pkgs2_4 = with pkgs; [
    postman # API development and testing tool
  ];

  # 2.6: Text Editors & IDEs
  pkgs2_6 = with pkgs; [
    emacs # Powerful text editor
    # emacs.vterm # Terminal emulator within Emacs
  ];

  # 2.7: Terminal & System Utilities
  pkgs2_7 = with pkgs; [
    kitty
    coreutils # Basic file, shell, and text utilities
    ripgrep # Fast text search tool
    fd # Simple, fast file finder
    clang # C language family compiler frontend
    libvterm # Terminal emulator library
    fastfetch # System information tool for the terminal
    usb-modeswitch
  ];

  # 2.8: Calculator
  pkgs2_8 = with pkgs; [
    qalculate-gtk # Feature-rich GTK calculator
    parsify # Next generation notepad-based calculator, built with extendibility and privacy in mind
    speedcrunch # Fast power user calculator
  ];

  # 2.9: Camera & File Management Tools
  pkgs2_9 = with pkgs; [
    droidcam # Stream your Android camera to your PC
    atool # Archive management tool (alternative to file managers like ranger)
  ];

  # 2.10: Video Processing & Utilities
  pkgs2_10 = with pkgs; [
    v4l-utils # Tools for Video4Linux devices
    ffmpeg_6 # Multimedia framework for video/audio processing
    ffmpegthumbnailer # Generates thumbnails from video files
  ];

  # 2.11: Virtualization
  pkgs2_11 = with pkgs; [
    qemu # Machine emulator and virtualizer
  ];

  # 2.12: PDF & Document Handling
  pkgs2_12 = with pkgs; [
    zathura # Lightweight and customizable PDF viewer
    texliveFull # Full TeX distribution for document compilation
    poppler-utils # Utilities for PDF manipulation
    freetype
    fontconfig
  ];

  # 2.13: System Monitoring & Information Tools
  pkgs2_13 = with pkgs; [
    upscayl # AI-powered image upscaling tool
    btop # Resource monitor for system metrics
    lm_sensors # Hardware monitoring tool
    mission-center
    s-tui
    stress
  ];

  # 2.14: Networking Tools
  pkgs2_14 = with pkgs; [
    git # Distributed version control system
    gh # GitHub command-line interface
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Codex CLI
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Claude Code
    wirelesstools # Tools for managing wireless interfaces
    docker-compose # Define and run multi-container Docker applications
    wavemon # Network analysis tool (verify details online)
  ];

  # 2.15: Browsers & Internet Utilities
  pkgs2_15 = with pkgs; [
    # Firefox with custom native messaging hosts for pipewire audio capture.
    #(firefox.override { nativeMessagingHosts = [ inputs.pipewire-screenaudio.packages.${pkgs.stdenv.hostPlatform.system}.default ]; })
    ungoogled-chromium
    w3m # Text-based web browser
  ];

  # 2.16: Communication Tools
  pkgs2_16 = with pkgs; [
    # Keep Thunderbird's ONNX dependency CPU-only even when CUDA is enabled globally.
    (wrapThunderbird
      (thunderbird-unwrapped.override {
        onnxruntime = onnxruntime.override {
          cudaSupport = false;
        };
      })
      { })
    # Official Discord clients patched with Vencord and NVIDIA screen sharing.
    discordNvenc
    discordCanaryNvenc
  ];

  # 2.17: Text Processing & Document Conversion
  pkgs2_17 = with pkgs; [
    glow # Terminal Markdown reader
    pandoc # Universal document converter
  ];

  # 2.18: Download Managers & VPN Tools
  pkgs2_18 = with pkgs; [
    nzbget # NZB download tool
    motrix # Multi-protocol download manager
    wget # Command-line network downloader
  ];

  # 2.19: Finance Management
  pkgs2_19 = with pkgs; [
    ledger # Command-line accounting tool
    # ledger-web          # Ledger web interface (currently commented out)
  ];

  # 2.20: Python Environment Management
  pkgs2_20 = with pkgs; [
    conda # Python package, dependency, and environment manager
    uv
  ];

  # 2.21: Media Players & Streaming Tools
  pkgs2_21 = with pkgs; [
    openNow # Open-source GeForce NOW desktop client
    mpv # Versatile media player
    yt-dlp # Command-line YouTube downloader
    pamixer # Command-line PulseAudio mixer utility
    pavucontrol # Graphical PulseAudio volume control
    easyeffects # Audio effects processor
  ];

  # 2.22: Compression & Archiving Tools
  pkgs2_22 = with pkgs; [
    zip # ZIP archiver
    unzip # Tool to extract ZIP archives
    _7zz # 7-Zip archiving tool
    _7zz-rar # 7-Zip with RAR support
    unrar # Extractor for RAR archives
  ];

  # 2.23: Additional Utilities
  pkgs2_23 = with pkgs; [
    xdg-utils # Utilities for XDG-compliant desktop environments
    gnome-disk-utility # Graphical disk utility for managing storage
    gdu # Disk usage analyzer
  ];

  # 2.25: Screenshots & Wallpaper Management
  pkgs2_25 = with pkgs; [
    hyprshot # Screenshot utility for Hyprland
    hyprpicker # Color picker for Hyprland
    grim # Grab images from a Wayland compositor
    slurp # Select a region in a Wayland compositor
    satty # Screenshot annotation tool
    swaybg # Wallpaper setter for Wayland compositors
    ksnip
  ];

  # 2.26: Brightness Control Utilities
  pkgs2_26 = with pkgs; [
    wluma # Utility to adjust brightness in Wayland
    brightnessctl # Command-line brightness controller
  ];

  # 2.28: Xorg Specific Tools
  pkgs2_28 = with pkgs; [
    xdotool # Automate X window interactions
    xprop # Utility to display window properties in X
    unixtools.xxd # Hex dump utility
    xwininfo # Display information about X windows
    yad # Yet Another Dialog for X (GUI dialogs)
    steam-run # Run programs in FHS environment
  ];

in
{
  ##############################################################
  # 1. Program and Service Enablings
  ##############################################################
  # Enable Java support.
  programs.java.enable = true;

  # Steam configuration: enables Steam along with firewall rules for remote play and dedicated server,
  # plus enabling a gamescope session for improved gaming performance.
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
    extest.enable = true; # Fixes invisible/desync cursor with Steam Input "As Mouse" on Wayland
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraPackages = with pkgs; [
      flatpak
    ];
    #   gamescopeSession.enable = true;
    #
  };
  programs.gamescope.enable = true;

  ##############################################################
  # 2. System-Wide Packages
  ##############################################################
  environment.systemPackages =
    pkgs2_0 ++
    pkgs2_1 ++
    pkgs2_2 ++
    pkgs2_3 ++
    pkgs2_4 ++
    pkgs2_6 ++
    pkgs2_7 ++
    pkgs2_8 ++
    pkgs2_9 ++
    pkgs2_10 ++
    pkgs2_11 ++
    pkgs2_12 ++
    pkgs2_13 ++
    pkgs2_14 ++
    pkgs2_15 ++
    pkgs2_16 ++
    pkgs2_17 ++
    pkgs2_18 ++
    pkgs2_19 ++
    pkgs2_20 ++
    pkgs2_21 ++
    pkgs2_22 ++
    pkgs2_23 ++
    pkgs2_25 ++
    pkgs2_26 ++
    pkgs2_28 ++
    unstableGamingPkgs ++
    unstableCompatibilityPkgs;
}
