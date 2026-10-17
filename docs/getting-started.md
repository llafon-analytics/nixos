# Démarrage

## Prérequis

- Nix avec les fonctionnalités `nix-command` et `flakes`.
- Un host déclaré dans `flake/hosts.nix` (`desktop` ou `laptop`).

## Cloner le dépôt

Les modules Home Manager supposent que le dépôt se trouve dans `~/Documents/nix-configuration`
(alias `nh`, scratchpad de documentation).

```sh
git clone https://github.com/llafon-analytics/nixos.git ~/Documents/nix-configuration
cd ~/Documents/nix-configuration
```

## Environnement de travail

```sh
nix develop          # ou `direnv allow` : formatteur, linters, nixd, temp-fixes, MkDocs
nix flake show       # sorties de la flake
nix flake check --no-build
```

## Appliquer un host

```sh
sudo nixos-rebuild switch --flake .#desktop
sudo nixos-rebuild switch --flake .#laptop
```

Une fois installé, `nh os switch` reconstruit l'hôte courant (voir [Rebuild](operations/rebuild.md)).

## Après le premier switch

Tous les services réseau ne sont joignables que via Tailscale :

```sh
sudo tailscale up --auth-key=<VOTRE_CLE>
```
