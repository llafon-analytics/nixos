{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos
    ../../modules/nixos/hardware/amdgpu.nix
    ../../modules/nixos/hardware/tlp.nix
    ../../modules/nixos/hardware/rtw89.nix
    ../../modules/nixos/packages/laptop.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [
      80
      91
      443
      444
      8501
      9100
    ];
    allowedUDPPorts = [
      80
      91
      443
      444
      8501
      9100
    ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
      priority = 0;
    }
  ];

  # Let periodic TRIM reach the filesystem through the encrypted root volume.
  boot.initrd.luks.devices."luks-216678d1-6ca7-4d74-abd7-a81a930088d7".allowDiscards = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  boot.kernel.sysctl."vm.swappiness" = 20;

  home-manager.users.laptop = import ./home.nix;
  nix.settings.trusted-users = [ "laptop" ];

  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "laptop";
    defaultSession = "hyprland";
  };
  services.desktopManager.plasma6.enable = true;

  # Disable Caps Lock (scancode 3a).
  services.udev.extraHwdb = ''
    evdev:input:b*v*p*e*
     KEYBOARD_KEY_3a=reserved
  '';
}
