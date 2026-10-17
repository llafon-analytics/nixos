{ inputs, ... }:

# Every NixOS module shared by all hosts. Hosts import this file and then add
# their hardware, users and host-only modules (see hosts/<host>/default.nix).
{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.nix-index-database.nixosModules.nix-index
    inputs.home-manager.nixosModules.home-manager

    ./base/boot.nix
    ./base/locale.nix
    ./base/nix.nix
    ./base/system.nix
    ./base/users.nix
    ./network.nix
    ./home-manager.nix
    ./desktop
    ./printing.nix
    ./gaming
    ./hardware/logitech.nix
    ./packages/common.nix
  ];
}
