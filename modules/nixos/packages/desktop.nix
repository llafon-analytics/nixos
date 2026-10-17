{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

# Desktop-only packages (NVIDIA workstation), grouped by domain.
let
  groups = {
    audio = with pkgs; [
      reaper
      yabridge # Bridges Windows plugins
      yabridgectl
    ];

    video = with pkgs; [ davinci-resolve ];

    virtualisation = with pkgs; [ quickemu ];

    benchmarks = with pkgs; [ phoronix-test-suite ];

    steam = with pkgs; [
      sgdboop # Steam artwork manager
    ];

    # Fast-moving gaming/VR tools.
    unstable = with pkgs-unstable; [
      alvr
      nvidia_oc
    ];
  };
in
{
  environment.systemPackages = lib.concatLists (lib.attrValues groups);
}
