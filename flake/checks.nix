{ self, ... }:

{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      # Text sources only: the checks never need images or the docs.
      textSources = lib.fileset.toSource {
        root = ../.;
        fileset = lib.fileset.fileFilter (
          file:
          lib.any file.hasExt [
            "nix"
            "lua"
            "sh"
            "py"
            "toml"
            "conf"
            "el"
          ]
        ) ../.;
      };
    in
    {
      checks = {
        # Evaluated by `nix flake check --no-build`, built only on demand.
        desktop = self.nixosConfigurations.desktop.config.system.build.toplevel;
        laptop = self.nixosConfigurations.laptop.config.system.build.toplevel;

        temp-fixes-lint = pkgs.runCommand "temp-fixes-lint" { } ''
          ${lib.getExe self'.packages.temp-fixes} --registry ${textSources}/temp-fixes.toml lint
          touch $out
        '';

        hyprland-lua =
          pkgs.runCommand "hyprland-lua-syntax"
            {
              nativeBuildInputs = [ pkgs.lua ];
            }
            ''
              cd ${textSources}
              for file in modules/home/hyprland/hyprland.base.lua hosts/*/hyprland.lua; do
                luac -p "$file"
              done
              touch $out
            '';
      };
    };
}
