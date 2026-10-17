{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      meslo-lgs-nf
      corefonts
      nerd-fonts.jetbrains-mono
      dejavu_fonts
      liberation_ttf
      material-symbols # Caelestia icon font; its bar renders boxes without it.
      nerd-fonts.caskaydia-cove # Caelestia default UI font.
    ];
    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
        autohint = true;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };
}
