{ pkgs, ... }:

# Home Manager configuration shared by every user/host.
# Host-specific additions live in hosts/<host>/home.nix.
{
  imports = [
    ./caelestia.nix
    ./zen-browser.nix
    ./vscode.nix
    ./zsh.nix
    ./cli-tools.nix
    ./pyprland.nix
    ./neovim.nix
    ./fastfetch.nix
    ./hyprland
  ];

  # Release whose Home Manager defaults this configuration was written against.
  # Only change it after reading the Home Manager release notes.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # `temp-fixes` CLI for the registry of temporary workarounds (temp-fixes.toml).
  home.packages = [ (pkgs.callPackage ../../pkgs/temp-fixes/package.nix { }) ];

  home.file = {
    ".config/nvim/lua/coc.lua".source = ../../dotfiles/nvim/coc.lua;
    ".config/btop/themes/catppuccin_latte.theme".source =
      ../../dotfiles/btop/themes/catppuccin_latte.theme;
    ".config/btop/themes/catppuccin_mocha.theme".source =
      ../../dotfiles/btop/themes/catppuccin_mocha.theme;
    ".config/YouTube Music/latte.css".source = ../../dotfiles/youtube-music/latte.css;
    ".config/hypr/hyprlock.conf".source = ../../dotfiles/hyprlock/hyprlock.conf;
    ".config/hypr/catppuccin_hyprlock_background_pink.jpg".source =
      ../../dotfiles/hyprlock/catppuccin_hyprlock_background_pink.jpg;
    ".config/hypr/latte.conf".source = ../../dotfiles/hyprlock/latte.conf;
    "Pictures/Wallpapers/wall3.png".source = ../../dotfiles/wallpaper/wall3.png;
    ".config/doom/init.el".source = ../../dotfiles/doom/init.el;
    ".config/doom/config.el".source = ../../dotfiles/doom/config.el;
    ".config/doom/packages.el".source = ../../dotfiles/doom/packages.el;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Alto";
      email = "lafon.ludovic.ll@proton.me";
    };
  };

  services.syncthing.enable = true;
}
