# Updating the flake

## Automatic (CI)

The `update-flake-lock.yml` workflow runs every Monday. It opens a
"chore(flake): update flake.lock" PR, evaluates both hosts and comments on the PR with:

- the per-host package version diff;
- the result of the [temporary fixes](../reference/temp-fixes.md) removal tests.

The `build-laptop.yml` workflow also builds the laptop system on that PR (non-blocking).

## Manual

```sh
nix flake update                 # every input
nix flake update nixpkgs         # one input
```

## Branch policy

- `nixpkgs`, `home-manager` and `stylix` stay on the current stable release.
- `nixpkgs-unstable` is for explicit exceptions.
- A stable release change updates the branches in `flake.nix`, then the lock.

## Check after an update

```sh
nix flake check --no-build
nix run .#temp-fixes -- check --all
nh os test                       # then nh os switch if all is well
```
