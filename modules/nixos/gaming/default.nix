{ pkgs, pkgs-unstable, ... }:

let
  # TEMP-FIX(lsfg-vk-static-libstdcxx): the layer is injected into every Vulkan process; linking libstdc++ statically avoids
  # "GLIBCXX_3.4.35 not found" when the host process already loaded an older libstdc++.
  lsfgVkStatic = pkgs-unstable.lsfg-vk.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DCMAKE_SHARED_LINKER_FLAGS=-static-libstdc++ -static-libgcc"
    ];
  });
in
{
  # Fast-moving gaming packages come from unstable on purpose.
  environment.systemPackages = [
    pkgs.lutris
  ]
  ++ (with pkgs-unstable; [
    winetricks
    dosbox-staging
    wineWow64Packages.waylandFull
    gamescope
    prismlauncher
    mangohud
    heroic
    protonup-qt
    protontricks
    gwe
    lsfgVkStatic
    lsfg-vk-ui
    steamtinkerlaunch
  ]);

  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
    extest.enable = true; # Fixes invisible/desync cursor with Steam Input "As Mouse" on Wayland
    # Ports stay closed on the LAN: everything goes through Tailscale.
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
    extraPackages = with pkgs; [ flatpak ];
    gamescopeSession.enable = true;
  };
  programs.gamescope.enable = true;

  programs.gamemode = {
    enable = true;
    enableRenice = false;
    settings = {
      general = {
        desiredgov = "performance";
        desiredprof = "performance";
        disable_splitlock = 1;
      };
    };
  };

  # Wolf (game streaming server) virtual input devices.
  services.udev.extraRules = ''
    # Allows Wolf to access /dev/uinput
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"

    # Allows Wolf to access /dev/uhid
    KERNEL=="uhid", TAG+="uaccess"

    # Move virtual keyboard and mouse into a different seat
    SUBSYSTEMS=="input", ATTRS{id/vendor}=="ab00", MODE="0660", GROUP="input", ENV{ID_SEAT}="seat9"

    # Joypads
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf X-Box One (virtual) pad", MODE="0660", GROUP="input"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf PS5 (virtual) pad", MODE="0660", GROUP="input"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf gamepad (virtual) motion sensors", MODE="0660", GROUP="input"
    SUBSYSTEMS=="input", ATTRS{name}=="Wolf Nintendo (virtual) pad", MODE="0660", GROUP="input"
  '';
}
