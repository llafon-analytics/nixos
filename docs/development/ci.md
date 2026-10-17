# CI

Workflows GitHub Actions dans `.github/workflows/` :

| Workflow | Déclencheur | Rôle |
|---|---|---|
| `ci.yml` | push sur `main`, PR | job **lint** (checks `treefmt`, `temp-fixes-lint`, `hyprland-lua`) et job **eval** (`nix flake check --no-build`, évalue les deux hosts) |
| `docs.yml` | changements de `docs/` ou `mkdocs.yml` | `mkdocs build --strict` ; déploiement GitHub Pages depuis `main` |
| `update-flake-lock.yml` | lundi 04:00 UTC, manuel | PR de mise à jour du lock + commentaire (diff de versions, tests de retrait des fix temporaires) |
| `temp-fixes-review.yml` | lundi 07:00 UTC, manuel | issue unique « Revue des fix temporaires » listant les fix en retard |
| `build-laptop.yml` | PR modifiant `flake.lock`, manuel | build complet du laptop (non bloquant) |

## Limites

- Le **desktop n'est pas construit** en CI : CUDA global, DaVinci Resolve et modules noyau
  dépassent les capacités d'un runner hébergé. Il est évalué à chaque push.
- Une PR ouverte avec le `GITHUB_TOKEN` par défaut ne déclenche pas `ci.yml`. Pour avoir les checks
  sur les PR du lock, ajouter un secret `FLAKE_UPDATE_TOKEN` (PAT fine-grained : *contents* et
  *pull requests* en écriture). L'évaluation tourne de toute façon dans `update-flake-lock.yml`.
- Le déploiement de la documentation demande *Settings → Pages → Source : GitHub Actions*.

## À configurer dans GitHub

- Protection de `main` : exiger les checks `Lint (format, temp-fixes, Lua)` et `Evaluate both hosts`.
