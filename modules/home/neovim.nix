{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    coc.enable = true;
    defaultEditor = true;
    withRuby = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      nerdtree
      vim-nerdtree-tabs
      vim-nerdtree-syntax-highlight
      nvim-web-devicons
      vimtex
      coq-thirdparty
      coc-vimtex
      #copilot-vim
      vim-nix
      coc-sh
      coc-docker
      coc-css
      coc-yank
      coc-yaml
      coc-json
      coc-vimtex
      coc-highlight
      coc-markdownlint
      coc-nginx
      coc-pyright
    ];
    extraConfig =
      ''
        nnoremap <F4> :NERDTreeToggle<CR>
      '';
    initLua =
      ''
        require 'coc'
        vim.g.coq_settings = {auto_start = true}
        vim.cmd.colorscheme "catppuccin-latte"
        require("coq_3p") {
          { src = "copilot", short_name = "COP", accept_key = "<c-f>" },
        }
      '';
  };
}
