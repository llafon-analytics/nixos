{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    # `nix fmt` formats the repository; `checks.treefmt` fails on unformatted files.
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        shfmt.enable = true;
        stylua.enable = true;
      };
      settings.global.excludes = [
        "dotfiles/**"
        "docs/**"
        "*.md"
        "flake.lock"
      ];
    };
  };
}
