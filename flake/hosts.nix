{ inputs, ... }:

let
  mkHost = import ../lib/mkHost.nix { inherit inputs; };
in
{
  flake.nixosConfigurations = {
    desktop = mkHost { name = "desktop"; };
    laptop = mkHost { name = "laptop"; };
  };
}
