{ pkgs, ... }:

{
  users.users.laptop = {
    isNormalUser = true;
    description = "laptop";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "gamemode"
      "input"
    ];
  };

  users.users.desktop = {
    isNormalUser = true;
    description = "desktop";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "docker"
      "gamemode"
      "input"
    ];
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
}
