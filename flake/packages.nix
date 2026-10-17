{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        temp-fixes = pkgs.callPackage ../pkgs/temp-fixes/package.nix { };
        mkdocs-env = pkgs.callPackage ../pkgs/mkdocs-env/package.nix { };
        opennow = pkgs.callPackage ../pkgs/opennow/package.nix { };
      };
    };
}
