# Documentation workflow

## Add / edit a page

1. Edit the page under `docs/` **and** its translation under `docs/en/`.
2. If needed, update the navigation in `mkdocs.yml` (both languages).
3. Preview.

```sh
nix develop -c mkdocs serve
```

`SUPER + ALT + é` also opens the live documentation (Pyprland scratchpad).

## Local build

```sh
nix develop -c mkdocs build --strict
```

`--strict` fails on a broken link or a page missing from the navigation; CI (`docs.yml`) runs the
same command.
