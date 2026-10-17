{
  config,
  lib,
  pkgs,
  ...
}:

# TEMP-FIX(rtw89-out-of-tree): TP-Link TXE70UH (Realtek RTL8852CU) USB Wi-Fi dongle, driven by the
# out-of-tree morrownr/rtw89 driver.
let
  kp = config.boot.kernelPackages;
  rtw89 = kp.callPackage ../../../pkgs/rtw89/package.nix {
    inherit (kp) kernel;
  };
  rtw89Firmware = pkgs.callPackage ../../../pkgs/rtw89-firmware/package.nix { };
in
{
  # Build the out-of-tree module against the kernel actually selected by this host.
  boot.extraModulePackages = [ rtw89 ];

  # Let udev/modprobe autoload the right module names from modaliases instead of
  # hardcoding a possibly incorrect alias such as `rtw89usb`.
  hardware.firmware = [ rtw89Firmware ];

  # The dongle first enumerates as a CD-ROM holding the Windows driver.
  hardware.usb-modeswitch.enable = true;
  services.udev.extraRules = ''
    # Switch TP-Link TXE70UH from CD-ROM to Wi‑Fi mode
    ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${lib.getExe pkgs.usb-modeswitch} -K -v 0bda -p 1a2b"
  '';

  environment.etc = {
    "modprobe.d/rtw89.conf".source = "${rtw89}/etc/modprobe.d/rtw89.conf";

    # Recommended by morrownr/rtw89 (Q6) to prevent long boot times when the
    # USB dongle is already inserted at boot.
    "modprobe.d/usb_storage.conf".text = ''
      # This tells usb_storage not to touch Realtek USB Wi-Fi dongles.
      # Otherwise, computers may take a very long time to boot or
      # usb_modeswitch may fail to switch them to Wi-Fi mode.
      options usb_storage quirks=0bda:1a2b:i,0bda:a192:i
    '';
  };
}
