{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = [ (pkgs.callPackage ./pkgs/mkdocs-env/package.nix { }) ];
}
