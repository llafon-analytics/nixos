_:

{
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

  # Firewall policy: nothing is opened globally except what NixOS modules
  # need on the LAN (Avahi/mDNS for printer discovery, KDE Connect). Each host
  # opens its service ports on the tailscale0 interface only.
  # Loose reverse path filtering, needed by Tailscale exit nodes/subnet routes.
  networking.firewall.checkReversePath = "loose";

  services.tailscale = {
    enable = true;
    # UDP 41641, for direct (non-relayed) connections between peers.
    openFirewall = true;
    extraSetFlags = [ "--ssh" ];
  };

  # Skip waiting for full network connectivity during boot.
  systemd.services."NetworkManager-wait-online".enable = false;
}
