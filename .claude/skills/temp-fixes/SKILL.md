---
name: temp-fixes
description: Add, review, challenge or resolve an entry of the temporary-fix registry (temp-fixes.toml). Use when introducing a workaround (pinned or unstable package, corrective overlay, mkForce against a module, patch, compatibility flag), when the user asks about temporary fixes, when a session starts with overdue fixes, after a flake.lock update, or when editing a file that carries a TEMP-FIX(<id>) marker.
---

# Registre des fix temporaires

Le registre est `temp-fixes.toml` à la racine du dépôt ; chaque entrée active a un commentaire
`TEMP-FIX(<id>)` à côté du code. L'outil `temp-fixes` (ou `nix run .#temp-fixes --`) le consulte :

```sh
temp-fixes list [--status active|resolved|all] [--host desktop|laptop] [--format markdown]
temp-fixes show <id>
temp-fixes due [--format text|markdown|brief]
temp-fixes check <id>... | --all      # lance les removal_test
temp-fixes lint                       # cohérence registre ↔ marqueurs (aussi en CI)
```

Parle à l'utilisateur en français.

## Ajouter un fix

1. Choisis un `id` court en kebab-case (`solaar-unstable`, `discord-no-vaapi-decode`).
2. Ajoute l'entrée à la fin de `temp-fixes.toml` :

   ```toml
   [[fix]]
   id = "mon-fix"
   title = "Résumé d'une ligne"
   status = "active"
   hosts = ["desktop", "laptop"]          # hôtes concernés
   files = ["modules/nixos/…/fichier.nix"] # tous les fichiers portant le marqueur
   reason = "Pourquoi ce contournement existe (symptôme, erreur exacte)."
   removal_condition = "Ce qui doit être vrai pour pouvoir le retirer."
   removal_test = "commande qui RÉUSSIT quand le fix n'est plus nécessaire"  # optionnel
   upstream = "https://…"                  # optionnel : issue / PR upstream
   added = AAAA-MM-JJ
   review_after = AAAA-MM-JJ               # par défaut : +6 semaines
   history = ["AAAA-MM-JJ : créé (contexte)."]
   ```

3. Pose `# TEMP-FIX(mon-fix): …` dans chaque fichier listé, **en commentaire Nix** (pas à l'intérieur
   d'une chaîne `''…''`, sinon la dérivation change).
4. `temp-fixes lint` doit passer.

Idées de `removal_test` (lancées depuis la racine du dépôt) :

- paquet stable qui construit de nouveau : `nix build --no-link --inputs-from . nixpkgs#<attr>`
- paquet arrivé dans stable : `nix eval --inputs-from . nixpkgs#<attr>.version`
- version suffisante : `v=$(nix eval --raw .#…version) && [ "$(printf '%s\n' X "$v" | sort -V | head -n1)" = X ]`
- module nixpkgs corrigé : `! grep -q <motif> "$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.nixpkgs.outPath')/nixos/modules/…"`

## Revoir / challenger un fix

1. `temp-fixes show <id>` puis `temp-fixes check <id>` s'il a un test.
2. Si possible, regarde l'état upstream (issue, changelog, version dans nixpkgs).
3. Présente à l'utilisateur, en 3–4 lignes : le fix, ce que tu as vérifié, ta recommandation
   (retirer, garder, tester d'une certaine façon).
4. Consigne la décision :
   - gardé : `last_challenged = <aujourd'hui>`, nouveau `review_after`, une ligne dans `history`
     avec la raison ;
   - retiré : voir ci-dessous.

## Résoudre un fix

1. Retire le contournement **et** le marqueur `TEMP-FIX(<id>)`.
2. Dans l'entrée : `status = "resolved"`, `resolved = <aujourd'hui>`, ligne dans `history`
   (ce qui l'a rendu inutile). L'entrée reste comme historique.
3. Vérifie : `temp-fixes lint`, puis l'évaluation de l'hôte (`drvPath`, `nix-diff` si utile) ; signale
   ce que l'utilisateur doit tester après reconstruction.
4. Commit dédié : `fix: resolve temp-fix <id>` avec l'explication.
