# Builds one NixOS host from hosts/<name>. Every host gets `inputs` and a
# separate unstable package set (`pkgs-unstable`) as module arguments.
{ inputs }:
{
  name,
  system ? "x86_64-linux",
}:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  modules = [
    { nixpkgs.hostPlatform = system; }
    ../hosts/${name}
  ];
}
