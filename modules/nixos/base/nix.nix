_:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # The `nixpkgs` registry entry and NIX_PATH (`<nixpkgs>`, `nix-shell -p`) point
  # at this flake's nixpkgs input automatically (nixpkgs.flake.setNixPath and
  # setFlakeRegistry, set because the system is built from a flake).
  nix.channel.enable = false;

  # `, <command>` runs a program from nixpkgs without installing it. The
  # nix-index-database module also replaces command-not-found, which has no
  # database on a flake-only system, with the nix-index handler.
  programs.nix-index-database.comma.enable = true;
}
