# Mise à jour de la flake

## Automatique (CI)

Le workflow `update-flake-lock.yml` tourne chaque lundi. Il ouvre une PR
« chore(flake): update flake.lock », évalue les deux hosts et commente la PR avec :

- le diff des versions de paquets par host ;
- le résultat des tests de retrait des [fix temporaires](../reference/temp-fixes.md).

Le workflow `build-laptop.yml` construit en plus le système du laptop sur la PR (non bloquant).

## Manuelle

```sh
nix flake update                 # tous les inputs
nix flake update nixpkgs         # un input précis
```

## Politique de branches

- `nixpkgs`, `home-manager` et `stylix` restent alignés sur la release stable courante.
- `nixpkgs-unstable` sert aux exceptions explicites.
- Un changement de release stable met à jour les branches concernées dans `flake.nix`, puis le lock.

## Vérifier après mise à jour

```sh
nix flake check --no-build
nix run .#temp-fixes -- check --all
nh os test                       # puis nh os switch si tout va bien
```
