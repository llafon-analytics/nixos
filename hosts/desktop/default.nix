{ desktopPorts ? import ./ports.nix, ... }:
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-craftapps.nixosModules.default
    ../../hardware-configuration-desktop.nix
    ../../nvidiagpu.nix
    ../../packages/desktop.nix
    ../../modules/gamemode-optimizations.nix
    ../../drivers/rtw89.nix
  ];

  programs.craftapps = {
    enable = true;
    apps.photocraft.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = desktopPorts;
    allowedUDPPorts = desktopPorts;
  };

  services.openssh = {
    enable = true;
    ports = [ 2268 ];
  };

  # Avoid large temporary and persistent writes when desktop applications crash.
  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  home-manager.users.desktop = import ../../home-desktop.nix;
  home-manager.backupFileExtension = "backup";

  nix.settings.trusted-users = [ "desktop" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    # With live-restore on, dockerd exits without stopping anything and the
    # containerd-shims outlive docker.service (KillMode=process). They then sit
    # through systemd-shutdown's 90s SIGTERM grace period — shims ignore SIGTERM
    # and postgres reads it as a smart shutdown — before being SIGKILLed, which
    # is where the two minutes of shutdown went. Turning it off hands the
    # containers back to dockerd, which stops them with their own StopSignal.
    live-restore = false;
    # Only honoured when live-restore is off. 10s leaves room for a database
    # checkpoint instead of forcing WAL recovery on the next start.
    shutdown-timeout = 10;
  };
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  boot.kernel.sysctl."vm.swappiness" = 60;
  # Let periodic TRIM reach the filesystem through the encrypted root volume.
  boot.initrd.luks.devices."nvme0n1p1_crypt".allowDiscards = true;
  boot.kernelParams = [
    "nowatchdog"
  ];
  boot.blacklistedKernelModules = [ "sp5100_tco" ];

  # Prefer weekly TRIM over continuous discard on file deletion.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.displayManager = {
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "desktop";
    sddm.wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "hyprland";

  hardware.nvidia-container-toolkit.enable = true;

  # LACT provides monitoring, fan control and overclocking for the NVIDIA GPU.
  # The package ships the lactd unit; registering it with systemd makes it
  # available and starts it at boot.
  environment.systemPackages = [ pkgs.lact pkgs.furmark ];
  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

}
