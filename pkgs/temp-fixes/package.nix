# CLI for the temporary-fix registry (temp-fixes.toml), see docs/reference/temp-fixes.md.
{ writers }:

writers.writePython3Bin "temp-fixes" {
  # Long user-facing strings; line length is not worth wrapping them.
  flakeIgnore = [ "E501" ];
} (builtins.readFile ./temp_fixes.py)
