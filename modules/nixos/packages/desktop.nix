{ pkgs, pkgs-unstable, ... }:

let
  unstableGamingDesktopPkgs = with pkgs-unstable; [
    alvr # VR
    nvidia_oc
  ];

  # 3.1: Digital Audio Workstations (DAWs)
  pkgs3_1 = with pkgs; [
    reaper # Main DAW application
    yabridge # Bridges Windows plugins
    yabridgectl # CLI helper for yabridge
  ];

  # 3.2: Video Editing
  pkgs3_2 = with pkgs; [
    davinci-resolve # Professional video editor
  ];

  # 3.3: Virtualization
  pkgs3_3 = with pkgs; [
    qemu
    quickemu
  ];

  # 3.4: Bench & Overcklocking
  pkgs3_4 = with pkgs; [
    phoronix-test-suite
  ];

  # 3.5: Steam utilities
  pkgs3_5 = with pkgs; [
    sgdboop # Steam artwork manager
  ];

in
{
  environment.systemPackages =
    pkgs3_1 ++ pkgs3_2 ++ pkgs3_3 ++ pkgs3_4 ++ pkgs3_5 ++ unstableGamingDesktopPkgs;
}
