{ pkgs, ... }:

{
  time.timeZone = "Europe/Paris";

  # English locale, French keyboard layout.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    xkb.layout = "fr";
    xkb.variant = "";
  };

  console.keyMap = "fr";
  console = {
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
    font = "ter-u32n";
  };
}
