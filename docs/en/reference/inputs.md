# Flake inputs

## Declared inputs

| Input | Source | Main use |
|---|---|---|
| `nixpkgs` | `github:nixos/nixpkgs/nixos-26.05` | default stable base for packages/modules |
| `nixpkgs-unstable` | `github:NixOS/nixpkgs/nixpkgs-unstable` | explicit fast-moving exceptions, mostly gaming/compatibility |
| `home-manager` | `github:nix-community/home-manager/release-26.05` | user configuration, follows `nixpkgs` |
| `stylix` | `github:danth/stylix/release-26.05` | theming on the stable branch, follows `nixpkgs` |
| `flake-parts` | `github:hercules-ci/flake-parts` | flake output structure |
| `treefmt-nix` | `github:numtide/treefmt-nix` | formatter and linters (`nix fmt`) |
| `nix-craftapps` | `github:olafkfreund/nix-craftapps` | Photocraft (desktop), follows `nixpkgs` |
| `codex-cli-nix` | `github:sadjow/codex-cli-nix` | `codex` package, follows `nixpkgs-unstable` |
| `claude-code-nix` | `github:sadjow/claude-code-nix` | `claude` package, follows `nixpkgs-unstable` |
| `caelestia-shell` | `github:caelestia-dots/shell` | Caelestia shell (bar, launcher, lockscreen), follows `nixpkgs-unstable` |
| `millennium` | `github:SteamClientHomebrew/Millennium/next?dir=packages/nix` | overlay and Millennium-patched Steam package |
| `zen-browser` | `github:0xc000022070/zen-browser-flake` | browser package and Home Manager module (beta channel, follows `nixpkgs-unstable`) |
| `nix-index-database` | `github:nix-community/nix-index-database` | prebuilt weekly nix-index database for comma and command-not-found, follows `nixpkgs` |
| `catppuccin-zen` | `github:catppuccin/zen-browser` (non-flake) | Catppuccin Latte CSS and logo, Pink accent, for Zen |

## Check locked versions

```sh
nix flake metadata
```

or read `flake.lock` directly.

## Branch policy

- Keep `nixpkgs`, `home-manager` and `stylix` on the same stable release.
- Do not add a parallel stable input: `nixpkgs` already is the stable base.
- Add `inputs.nixpkgs.follows` to new inputs when possible, so that `flake.lock` does not
  accumulate nixpkgs copies.
- Use `nixpkgs-unstable` only for a named, localised exception.

## Zen Browser

- The shared `modules/home/zen-browser.nix` module enables Zen through Home Manager and applies Catppuccin Latte with the Pink accent.
- Zen alone uses `nixpkgs-unstable`, as its flake recommends for compatibility with recent Firefox versions.
- The CSS and `zen-logo-latte.svg` come straight from the locked `catppuccin-zen` input; nothing is downloaded when the browser starts.

## Tracked fixes

### Millennium

- Official source: <https://docs.steambrew.app/users/getting-started/installation>
- NixOS megathread: <https://github.com/SteamClientHomebrew/Millennium/issues/551>
- Applied fix: `millennium.inputs.nixpkgs.follows = "nixpkgs-unstable";`.
- Reason: the NixOS megathread recommends Millennium's `next` branch. Making Millennium follow `nixpkgs-unstable` keeps its packaging on a recent base without moving the whole stable system.
- Local workaround removed: the `overlays/millennium-compat.nix` overlay and the local copy of the packaging were dropped in favour of the official packaging.
- Maintenance note: use the `next` branch and, after adding or updating this input, update the lock with `nix flake update millennium`.
