{ inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "freeimage-unstable-2021-11-01"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [
    "nixpkgs=/etc/channels/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  environment.etc."channels/nixpkgs".source = inputs.nixpkgs.outPath;

  # `, <command>` runs a program from nixpkgs without installing it. The
  # nix-index-database module also replaces command-not-found, which has no
  # database on a flake-only system, with the nix-index handler.
  programs.nix-index-database.comma.enable = true;
}
