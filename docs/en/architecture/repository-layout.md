# Repository layout

| Path | Role |
|---|---|
| `flake.nix` | Flake inputs |
| `flake/` | Outputs (flake-parts): hosts, packages, checks, formatter, devShell |
| `lib/mkHost.nix` | Host builder |
| `hosts/<host>/` | `default.nix` (system), `hardware.nix`, `home.nix` (Home Manager), `hyprland.lua` |
| `modules/nixos/` | System modules; `default.nix` is the shared base |
| `modules/home/` | Home Manager modules; `common.nix` is what both users share |
| `pkgs/<name>/package.nix` | Local packages: `discord-nvenc`, `opennow`, `rtw89`, `rtw89-firmware`, `temp-fixes`, `mkdocs-env` |
| `overlays/` | nixpkgs overlays (listed in `overlays/default.nix`) and their patches |
| `dotfiles/` | Plain configuration files deployed by Home Manager |
| `scripts/` | Shell scripts (gamemode, Hyprland binds, agent hooks, CI) |
| `temp-fixes.toml` | Temporary-fix registry |
| `AGENTS.md`, `CLAUDE.md`, `.claude/` | AI agent instructions and configuration |
| `.github/workflows/` | GitHub Actions CI |
| `docs/` | MkDocs documentation (French, English under `docs/en/`) |
