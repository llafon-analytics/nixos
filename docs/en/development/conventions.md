# Conventions

## Nix

- One file per topic, imported explicitly.
- Keep the shared base (`modules/`) / host (`hosts/<host>/`) split.
- `nixpkgs`, `home-manager` and `stylix` on the current stable branch.
- Packages from `pkgs` by default; `pkgs-unstable` only for named exceptions.
- Every workaround is recorded in the [temporary-fix registry](../reference/temp-fixes.md) with a
  `TEMP-FIX(<id>)` marker.
- Formatting and linting: `nix fmt` (checked in CI).
- Do not rename a file copied into the store (dotfiles, Lua, patches) without reason: its name is
  part of the store path.
- Comments explain the *why* (constraint, worked-around bug), not the *what*.

## Git

- Conventional Commits, in English; one branch and one PR per topic.
- Bulk formatting commits are listed in `.git-blame-ignore-revs`:

  ```sh
  git config blame.ignoreRevsFile .git-blame-ignore-revs
  ```

## Documentation

- French in `docs/`, English in `docs/en/`: both are updated together.
- Copy-ready shell commands.
- Short, focused pages.
- Mark uncertain areas as **To be completed**.
