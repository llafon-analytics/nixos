{ inputs, imageMagickCompatOverlay }:
with inputs; [
  stylix.nixosModules.stylix
  ./configuration.nix
  home-manager.nixosModules.home-manager
  ({ pkgs-unstable, ... }: {
    nixpkgs.overlays = [
      imageMagickCompatOverlay
      inputs.millennium.overlays.default
    ];
    home-manager.extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    home-manager.sharedModules = [
      inputs.zen-browser.homeModules.beta
      inputs.caelestia-shell.homeManagerModules.default
      {
        nixpkgs.overlays = [
          imageMagickCompatOverlay
          inputs.millennium.overlays.default
        ];
      }
    ];
    home-manager.useGlobalPkgs = false;
    home-manager.useUserPackages = true;
  })
]
