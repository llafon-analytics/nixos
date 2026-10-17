{ pkgs-unstable, ... }:

{
  imports = [ ../../modules/home/common.nix ];

  home.username = "laptop";
  home.homeDirectory = "/home/laptop";

  # Laptop gaming/streaming exceptions use unstable; everything else stays on stable pkgs.
  home.packages = [ pkgs-unstable.moonlight-qt ];

  home.file.".config/YouTube Music/config.json".source = ../../dotfiles/youtube-music/config.json;
  xdg.configFile."hypr/host.lua".source = ./hyprland.lua;

  programs.git.signing.format = "openpgp";

  programs.zsh.shellAliases = {
    ac = "sudo tlp ac";
    bat = "sudo tlp start";
  };
}
