_:

{
  programs.kdeconnect.enable = true;
  programs.corectrl.enable = true;
  programs.java.enable = true;

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  # Yazi file manager, opening PDFs in zathura.
  programs.yazi = {
    enable = true;
    settings.yazi = {
      opener = {
        pdf = [
          {
            run = ''zathura "$@"'';
            block = true;
            for = "unix";
          }
        ];
      };
      open = {
        prepend_rules = [
          {
            mime = "application/pdf";
            use = "pdf";
          }
        ];
      };
    };
    settings.keymap = builtins.fromTOML (builtins.readFile ../../../dotfiles/yazi-keymap.toml);
  };
}
