{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  packages = [ (import ./hm/mkdocs-env.nix pkgs) ];
}
