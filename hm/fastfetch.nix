{ ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "file";
        source = ./fastfetch/nixos-braille.txt;
        color = {
          "1" = "38;5;110";
          "2" = "38;5;67";
        };
        padding = {
          top = 1;
          right = 2;
        };
      };
      display = {
        separator = " ";
      };
      modules = [
        "title"
        "separator"
        {
          type = "custom";
          format = "[38;5;97m  Système[0m";
        }
        {
          type = "os";
          key = "  OS";
          keyColor = "38;5;97";
          format = "{3} {13}";
        }
        {
          type = "kernel";
          key = "  Kernel";
          keyColor = "38;5;97";
        }
        {
          type = "wm";
          key = "  WM";
          keyColor = "38;5;97";
        }
        {
          type = "shell";
          key = "  Shell";
          keyColor = "38;5;97";
        }
        {
          type = "terminal";
          key = "  Terminal";
          keyColor = "38;5;97";
        }
        {
          type = "packages";
          key = "  Packages";
          keyColor = "38;5;97";
        }
        {
          type = "uptime";
          key = "  Uptime";
          keyColor = "38;5;97";
        }
        "break"
        {
          type = "custom";
          format = "[38;5;67m  Matériel[0m";
        }
        {
          type = "cpu";
          key = "  CPU";
          keyColor = "38;5;67";
        }
        {
          type = "gpu";
          key = "  GPU";
          keyColor = "38;5;67";
        }
        {
          type = "memory";
          key = "  Memory";
          keyColor = "38;5;67";
        }
        "break"
        {
          type = "colors";
          symbol = "block";
        }
      ];
    };
  };
}
