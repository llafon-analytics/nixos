{ inputs, pkgs-unstable, ... }:

{
  nixpkgs.overlays = import ../../overlays { inherit inputs; };

  home-manager = {
    backupFileExtension = "backup";
    # Home Manager uses the system package set: same overlays, same config
    # (allowUnfree, cudaSupport on the desktop), one nixpkgs evaluation.
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    sharedModules = [
      inputs.zen-browser.homeModules.beta
      inputs.caelestia-shell.homeManagerModules.default
    ];
  };
}
