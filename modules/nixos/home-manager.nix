{ inputs, pkgs-unstable, ... }:

let
  overlays = import ../../overlays { inherit inputs; };
in
{
  nixpkgs.overlays = overlays;

  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    sharedModules = [
      inputs.zen-browser.homeModules.beta
      inputs.caelestia-shell.homeManagerModules.default
      { nixpkgs.overlays = overlays; }
    ];
    useGlobalPkgs = false;
    useUserPackages = true;
  };
}
