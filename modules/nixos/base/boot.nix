{ config, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Menu shown for 1s instead of the 5s default.
  boot.loader.timeout = 1;

  boot.supportedFilesystems = [ "ntfs" ];
  boot.plymouth.enable = true;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "204800";
  };

  # Custom kernel modules, built against the stable kernel selected by nixpkgs.
  # snd_aloop provides the ALSA loopback device droidcam needs for its audio stream.
  boot.kernelModules = [
    "v4l2loopback"
    "snd_aloop"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    # Configure v4l2loopback: virtual camera settings for apps like Skype, Zoom, and Teams.
    options v4l2loopback video_nr=0,1 exclusive_caps=1,1 card_label="Virtual Camera 0","OBS Camera"
  '';

  zramSwap = {
    enable = true;
    priority = 100;
  };
}
