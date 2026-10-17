{ config, pkgs, ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      ## CPU power management
      CPU_DRIVER_OPMODE_ON_AC      = "passive";
      CPU_DRIVER_OPMODE_ON_BAT     = "passive";
      CPU_SCALING_GOVERNOR_ON_AC   = "ondemand";
      CPU_SCALING_GOVERNOR_ON_BAT  = "conservative";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC              = 1;
      CPU_BOOST_ON_BAT             = 0;

      ## Platform profile
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      ## AMD Radeon graphics
      RADEON_DPM_STATE_ON_AC        = "performance";
      RADEON_DPM_STATE_ON_BAT       = "battery";
      RADEON_DPM_PERF_LEVEL_ON_AC   = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT  = "low";
      AMDGPU_ABM_LEVEL_ON_AC        = 0;
      AMDGPU_ABM_LEVEL_ON_BAT       = 3;

      ## USB autosuspend
      USB_AUTOSUSPEND  = 1;
      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_AUDIO = 1;

      ## Wireless
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      ## PCIe runtime and ASPM
      RUNTIME_PM_ON_AC  = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon xhci_hcd";
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      ## Storage power management
      SATA_LINKPWR_ON_AC      = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT     = "min_power";
      AHCI_RUNTIME_PM_ON_AC   = "auto";
      AHCI_RUNTIME_PM_ON_BAT  = "auto";
      AHCI_RUNTIME_PM_TIMEOUT = 15;
      DISK_APM_LEVEL_ON_AC    = "254 254";
      DISK_APM_LEVEL_ON_BAT   = "128 128";
      DISK_IOSCHED            = "keep";

      ## Audio power saving
      SOUND_POWER_SAVE_ON_AC       = 1;
      SOUND_POWER_SAVE_ON_BAT      = 1;
      SOUND_POWER_SAVE_CONTROLLER  = "Y";
    };
  };

  # Disable conflicting services
  services.power-profiles-daemon.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;
  systemd.services.systemd-rfkill.enable = false;
}
