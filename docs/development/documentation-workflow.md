# Workflow documentation

## Ajouter / modifier une page

1. Modifier la page sous `docs/` **et** sa traduction sous `docs/en/`.
2. Si nécessaire, mettre à jour la navigation dans `mkdocs.yml` (les deux langues).
3. Prévisualiser.

```sh
nix develop -c mkdocs serve
```

Le raccourci `SUPER + ALT + é` ouvre aussi la documentation en direct (scratchpad Pyprland).

## Build local

```sh
nix develop -c mkdocs build --strict
```

`--strict` échoue sur un lien cassé ou une page absente de la navigation ; la CI (`docs.yml`) lance
la même commande.
