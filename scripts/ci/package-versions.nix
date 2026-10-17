# name -> version of every system and Home Manager package of each host.
# Used by the flake.lock update workflow to summarise version changes:
#   nix eval --json --impure --expr 'import ./scripts/ci/package-versions.nix { flake = builtins.getFlake (toString ./.); }'
{ flake }:
let
  inherit (flake.inputs.nixpkgs) lib;

  entry =
    pkg:
    let
      attempt = builtins.tryEval {
        name = pkg.pname or (lib.getName pkg);
        value = pkg.version or (lib.getVersion pkg);
      };
    in
    if attempt.success then [ attempt.value ] else [ ];

  versions = pkgs: lib.listToAttrs (lib.concatMap entry (lib.filter lib.isDerivation pkgs));

  hostPackages =
    host:
    host.config.environment.systemPackages
    ++ lib.concatMap (user: user.home.packages) (lib.attrValues host.config.home-manager.users);
in
lib.mapAttrs (_: host: versions (hostPackages host)) flake.nixosConfigurations
