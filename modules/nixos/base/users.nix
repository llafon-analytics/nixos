{ pkgs, ... }:

# Each host declares its own user (hosts/<host>/default.nix); this module only
# sets what every user shares.
{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
}
