# Arborescence du dépôt

| Chemin | Rôle |
|---|---|
| `flake.nix` | Inputs de la flake |
| `flake/` | Sorties (flake-parts) : hosts, paquets, checks, formatter, devShell |
| `lib/mkHost.nix` | Fabrique d'un host |
| `hosts/<host>/` | `default.nix` (système), `hardware.nix`, `home.nix` (Home Manager), `hyprland.lua` |
| `modules/nixos/` | Modules système ; `default.nix` = socle commun |
| `modules/home/` | Modules Home Manager ; `common.nix` = partie commune aux deux utilisateurs |
| `pkgs/<nom>/package.nix` | Paquets locaux : `discord-nvenc`, `opennow`, `rtw89`, `rtw89-firmware`, `temp-fixes`, `mkdocs-env` |
| `overlays/` | Overlays nixpkgs (liste dans `overlays/default.nix`) et leurs patches |
| `dotfiles/` | Fichiers de configuration bruts déployés par Home Manager |
| `scripts/` | Scripts shell (gamemode, raccourcis Hyprland, hooks d'agents, CI) |
| `temp-fixes.toml` | Registre des fix temporaires |
| `AGENTS.md`, `CLAUDE.md`, `.claude/` | Consignes et configuration des agents IA |
| `.github/workflows/` | CI GitHub Actions |
| `docs/` | Documentation MkDocs (FR, et EN sous `docs/en/`) |
