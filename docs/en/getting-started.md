# Getting started

## Prerequisites

- Nix with the `nix-command` and `flakes` features.
- A host declared in `flake/hosts.nix` (`desktop` or `laptop`).

## Clone the repository

The Home Manager modules expect the repository in `~/Documents/nix-configuration`
(`nh` aliases, documentation scratchpad).

```sh
git clone https://github.com/llafon-analytics/nixos.git ~/Documents/nix-configuration
cd ~/Documents/nix-configuration
```

## Development environment

```sh
nix develop          # or `direnv allow`: formatter, linters, nixd, temp-fixes, MkDocs
nix flake show       # flake outputs
nix flake check --no-build
```

## Apply a host

```sh
sudo nixos-rebuild switch --flake .#desktop
sudo nixos-rebuild switch --flake .#laptop
```

Once installed, `nh os switch` rebuilds the current host (see [Rebuild](operations/rebuild.md)).

## After the first switch

Every network service is only reachable through Tailscale:

```sh
sudo tailscale up --auth-key=<YOUR_KEY>
```
