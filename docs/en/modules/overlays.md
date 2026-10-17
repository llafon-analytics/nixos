# Overlays

The list lives in `overlays/default.nix`; it is applied to the system package set, which Home
Manager shares (`useGlobalPkgs`).

## `overlays/droidcam-transform-buffer.nix`

Applies `overlays/patches/droidcam-transform-buffer.patch` to `droidcam`: fixes the leak of the
buffer allocated by `tjTransform` on every frame when a rotation is active.
Temporary fix `droidcam-transform-buffer`.

## `inputs.millennium.overlays.default`

Exposes `pkgs.millennium-steam`, used by `programs.steam.package`.

## Solaar overlay (`modules/nixos/hardware/logitech.nix`)

Replaces `solaar` with the unstable version (the stable version's test suite fails in the
sandbox). Temporary fix `solaar-unstable`.
