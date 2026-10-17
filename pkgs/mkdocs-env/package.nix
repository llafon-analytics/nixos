# Python environment for the MkDocs documentation (devShell and Pyprland docs scratchpad).
{ python3 }:
python3.withPackages (
  ps: with ps; [
    mkdocs
    mkdocs-material
    pymdown-extensions
  ]
)
