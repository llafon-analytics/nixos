# Python environment shared by `nix-shell mkdocs.nix` and the Pyprland docs scratchpad.
pkgs:
pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
  mkdocs
  mkdocs-material
  pymdown-extensions
])
