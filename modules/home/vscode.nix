{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;
      extensions = with pkgs.vscode-extensions; [
        github.copilot
        ms-python.python
        ms-python.vscode-pylance
        catppuccin.catppuccin-vsc
        grapecity.gc-excelviewer
        jnoortheen.nix-ide
        vscodevim.vim
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter-slideshow
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.jupyter-renderers
        ms-toolsai.jupyter-keymap
        arrterian.nix-env-selector
      ];
      userSettings = {
        "python.venvFolders" = [
          "\${workspaceFolder}"
        ];
        "python.terminal.activateEnvironment" = true;
        "workbench.colorTheme" = "Catppuccin Latte";
      };
    };
  };

  # Keep the Catppuccin extension theme instead of Stylix's generated theme.
  stylix.targets.vscode.enable = false;
}
