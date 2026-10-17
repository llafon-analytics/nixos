{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    powertop
    radeontop # AMD GPU usage monitor
  ];
}
