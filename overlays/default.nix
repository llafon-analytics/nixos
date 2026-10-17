# Overlays applied to both the NixOS and the Home Manager package sets.
{ inputs }:
[
  (import ./droidcam-transform-buffer.nix)
  (import ./imagemagick-compat.nix)
  inputs.millennium.overlays.default
]
