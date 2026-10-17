# Conventions

## Nix

- Un fichier par sujet, importé explicitement.
- Garder la séparation socle commun (`modules/`) / host (`hosts/<host>/`).
- `nixpkgs`, `home-manager` et `stylix` sur la branche stable courante.
- Paquets depuis `pkgs` par défaut ; `pkgs-unstable` réservé aux exceptions nommées.
- Tout contournement est inscrit dans le [registre des fix temporaires](../reference/temp-fixes.md)
  avec un marqueur `TEMP-FIX(<id>)`.
- Formatage et lint : `nix fmt` (vérifié en CI).
- Ne pas renommer un fichier copié dans le store (dotfiles, Lua, patches) sans raison : son nom
  fait partie du chemin.
- Commentaires : le *pourquoi* (contrainte, bug contourné), pas le *quoi*.

## Git

- Conventional Commits, en anglais ; une branche et une PR par sujet.
- Les commits de formatage massif sont listés dans `.git-blame-ignore-revs` :

  ```sh
  git config blame.ignoreRevsFile .git-blame-ignore-revs
  ```

## Documentation

- Français dans `docs/`, anglais dans `docs/en/` : les deux sont mis à jour ensemble.
- Commandes shell prêtes à copier.
- Pages courtes et ciblées.
- Marquer les zones incertaines avec **À compléter**.
