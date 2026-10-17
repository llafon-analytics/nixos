{
  perSystem =
    {
      config,
      pkgs,
      self',
      ...
    }:
    {
      # `nix develop` (or direnv): formatting, linting, docs and registry tools.
      devShells.default = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper
          self'.packages.temp-fixes
          self'.packages.mkdocs-env
          pkgs.deadnix
          pkgs.statix
          pkgs.nixd
          pkgs.nix-diff
          pkgs.shellcheck
          pkgs.lua
        ];
      };
    };
}
