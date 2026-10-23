# Overlays

La liste est dans `overlays/default.nix` ; elle est appliquée au jeu de paquets du système, que
Home Manager partage (`useGlobalPkgs`).

## `overlays/droidcam-transform-buffer.nix`

Applique `overlays/patches/droidcam-transform-buffer.patch` à `droidcam` : corrige la fuite du
buffer alloué par `tjTransform` à chaque image quand une rotation est active.
Fix temporaire `droidcam-transform-buffer`.

## `inputs.millennium.overlays.default`

Expose `pkgs.millennium-steam`, utilisé par `programs.steam.package`.
