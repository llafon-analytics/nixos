{ config, ... }:

{
  # Shell history in a searchable database (Ctrl+R). Everything stays local:
  # no sync, no update check, and no AI keybinding (`?`) talking to atuin.sh.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # Keep zsh's own Up-arrow history; Atuin only takes over Ctrl+R.
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      update_check = false;
      ai.enabled = false;
      # Enter puts the command back in the prompt, like zsh's native Ctrl+R.
      enter_accept = false;
      search_mode = "fuzzy";
      style = "compact";
    };
  };

  # `z <dir>` / `zi` (fzf picker); plain `cd` is left untouched.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Themed by Stylix; the zsh wrapper `lg` follows the repo you exit lazygit from.
  programs.lazygit.enable = true;

  # nh wraps nix-output-monitor, so rebuilds get nom's build tree and a package
  # diff without installing nom separately. The hostname selects the
  # nixosConfiguration (desktop or laptop).
  programs.nh = {
    enable = true;
    osFlake = "${config.home.homeDirectory}/Documents/nix-configuration";
  };
}
