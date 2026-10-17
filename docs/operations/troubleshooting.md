# Dépannage

## Commandes de base

```sh
nix flake show
nix flake check --no-build
git status        # la flake ne voit que les fichiers suivis par git
```

## Trace détaillée

```sh
nix eval --show-trace .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
sudo nixos-rebuild dry-activate --flake .#desktop --show-trace
```

## Comparer deux états

```sh
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath   # avant / après
nix run nixpkgs#nix-diff -- <ancien.drv> <nouveau.drv>
```

## Symptômes courants

| Symptôme | Vérification |
|---|---|
| Erreur flake | `nix flake check --no-build` |
| Fichier ajouté « introuvable » | `git add` le fichier (flake) |
| Host introuvable | `nix flake show`, puis `flake/hosts.nix` |
| Config Hyprland | `nix build .#checks.x86_64-linux.hyprland-lua`, `hyprctl configerrors` |
| Service injoignable depuis une autre machine | il n'est ouvert que sur Tailscale : `tailscale status` |
| Réseau / Tailscale | `systemctl status tailscaled` puis `tailscale status` |
