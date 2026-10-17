{ pkgs-unstable, ... }:

{
  # Logitech wireless devices, with Solaar as the graphical tool.
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  # TEMP-FIX(solaar-unstable): the stable 1.1.19 test suite fails in the sandbox.
  nixpkgs.overlays = [ (final: prev: { solaar = pkgs-unstable.solaar; }) ];
}
