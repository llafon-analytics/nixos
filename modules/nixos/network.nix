{ ... }:

{
  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.enableIPv6 = false;

  # Loose reverse path filtering, needed by Tailscale exit nodes/subnet routes.
  networking.firewall.checkReversePath = "loose";

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  networking.dhcpcd.wait = "background";
  networking.dhcpcd.extraConfig = ''
    timeout 1
    noarp
    nodelay
  '';

  # Skip waiting for full network connectivity during boot.
  systemd.services."NetworkManager-wait-online".enable = false;
}
