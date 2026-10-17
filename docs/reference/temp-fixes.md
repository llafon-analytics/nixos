# Fix temporaires

Un **fix temporaire** est un contournement qu'on espère retirer un jour : paquet épinglé ou pris
sur unstable parce que stable est cassé, overlay correctif, option forcée contre un module, patch,
flag de compatibilité… Ils sont recensés dans **`temp-fixes.toml`**, à la racine du dépôt, et
marqués dans le code par un commentaire `TEMP-FIX(<id>)`.

## Consulter

La commande `temp-fixes` est installée pour les deux utilisateurs (sinon `nix run .#temp-fixes --`).
Elle trouve le registre depuis le dossier courant ou, à défaut, dans `~/Documents/nix-configuration`.

```sh
temp-fixes list                     # fix actifs (« ! » = revue en retard)
temp-fixes list --status all --host desktop
temp-fixes show solaar-unstable
temp-fixes due                      # fix dont la date de revue est passée
temp-fixes check --all              # lance les tests de retrait automatiques
temp-fixes lint                     # cohérence registre ↔ marqueurs (aussi en CI)
```

`check` affiche ✅ quand le test de retrait passe (le fix peut sans doute être retiré), ⏳ sinon.

## Format d'une entrée

```toml
[[fix]]
id = "solaar-unstable"
title = "Solaar pris sur nixpkgs-unstable"
status = "active"                   # active | resolved
hosts = ["desktop", "laptop"]
files = ["modules/nixos/hardware/logitech.nix"]   # fichiers portant le marqueur
reason = "La suite de tests de solaar 1.1.19 échoue dans le sandbox."
removal_condition = "Le solaar de la branche stable construit."
removal_test = "nix build --no-link --inputs-from . nixpkgs#solaar"   # optionnel
upstream = "https://…"              # optionnel
added = 2026-10-17
review_after = 2026-11-28
last_challenged = 2026-10-17        # optionnel
resolved = 2026-12-01               # quand status = "resolved"
history = ["2026-10-17 : entrée créée lors de l'audit."]
```

`removal_test` est lancé depuis la racine du dépôt et doit **réussir quand le fix n'est plus
nécessaire**. `--inputs-from .` fait pointer `nixpkgs#…` sur l'input verrouillé de la flake.

## Être challengé régulièrement

| Quand | Quoi |
|---|---|
| Début de session Claude Code | le hook `SessionStart` donne à l'agent les fix en retard ; il vous en challenge au plus deux et consigne votre décision |
| Modification d'un fichier marqué | l'agent relit l'entrée et dit si le fix est encore justifié |
| PR hebdomadaire du lock | commentaire avec le résultat de `temp-fixes check --all` |
| Chaque lundi | issue GitHub « Revue des fix temporaires » mise à jour (commentaire si la liste change) |

## Décider

- **Garder** : mettre à jour `last_challenged`, `review_after` et ajouter une ligne à `history`.
- **Retirer** : supprimer le contournement et son marqueur, passer l'entrée en `resolved` avec la
  date et une ligne d'historique. L'entrée reste comme trace.

Un agent peut faire ces mises à jour (skill `temp-fixes`).
