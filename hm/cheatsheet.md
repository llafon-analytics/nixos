# Aide-mémoire

`SUPER + ALT + &` ouvre/ferme cette page · `q` pour quitter · détails : `docs/`

## Nouveautés

- Layout **scrolling** par workspace : `SUPER + CTRL + S`
- **Terminal escamotable** : `SUPER + SHIFT + Entrée`
- **Documentation NixOS** (MkDocs) en scratchpad : `SUPER + ALT + é`
- **ChatGPT** en scratchpad : `SUPER + ALT + "`
- Shell : **Atuin** (`Ctrl+R`), **zoxide** (`z`, `zi`), **Lazygit** (`lg`), **Lazydocker** (desktop)
- Nix : **nh** (`dupdate` / `lupdate`), **comma** (`, <commande>`)

## Fenêtres

| Raccourci | Action |
|---|---|
| `SUPER + Entrée` | terminal kitty |
| `SUPER + SHIFT + Entrée` | terminal escamotable (session conservée) |
| `SUPER + Z` | fermer la fenêtre |
| `SUPER + T` / `F` / `P` | flottant / plein écran / pseudo |
| `SUPER + H J K L` | focus gauche / bas / haut / droite |
| `SUPER + CTRL + H J K L` | déplacer la fenêtre |
| `SUPER + SHIFT + H J K L` | redimensionner |
| `SUPER + S` | changer le sens du split (dwindle) |
| `SUPER + CTRL + S` | workspace actif : dwindle ⇄ scrolling |
| `SUPER + 1…0` (rangée AZERTY) | aller au workspace |
| `SUPER + SHIFT + 1…0` | envoyer la fenêtre au workspace |

En **scrolling**, `H`/`L` passent d'une colonne à l'autre et la font défiler,
`K`/`J` naviguent dans la colonne. La bascule est perdue au rechargement
d'Hyprland (ou après une session GameMode).

## Scratchpads

| Raccourci | Action |
|---|---|
| `SUPER + SHIFT + Entrée` | terminal (session conservée) |
| `SUPER + ALT + &` | cet aide-mémoire |
| `SUPER + ALT + é` | documentation du dépôt (`mkdocs serve`, rechargement auto) |
| `SUPER + ALT + "` | ChatGPT (profil Chromium dédié, session conservée) |

Chaque raccourci affiche ou masque la fenêtre, sur le workspace actif. La
documentation lance son serveur au premier appel (`127.0.0.1:8765`) et l'arrête
quand la fenêtre est fermée ; une erreur de démarrage est notifiée
(`~/.local/state/pypr-docs/mkdocs.log`). Fermer ChatGPT puis rappeler `SUPER + ALT + "` le
relance, connecté.

## Bureau

| Raccourci | Action |
|---|---|
| `SUPER + espace` | launcher |
| `SUPER + W` | sélecteur de fenêtres (rofi) |
| `SUPER + V` | historique du presse-papiers |
| `SUPER + M` / `B` | dashboard / notifications |
| `SUPER + X` | verrouiller |
| `Impr` / `CTRL + Impr` | capture de zone / capture annotée |

## Shell

| Commande | Action |
|---|---|
| `Ctrl+R` | rechercher dans l'historique (Atuin, Entrée = éditer) |
| `z <motif>` · `zi` | aller dans un dossier fréquent · choix interactif |
| `lg` | Lazygit (le shell suit le dépôt ouvert à la sortie) |
| `lazydocker` | conteneurs Docker (desktop) |
| `, <commande>` | lancer un programme nixpkgs sans l'installer |

Une commande inconnue propose le paquet qui la fournit.

## Nix

| Commande | Action |
|---|---|
| `dupdate` / `lupdate` | rebuild + switch desktop / laptop (via nh) |
| `nh os test` · `nh os boot` | appliquer temporairement · au prochain démarrage |
| `nh search <motif>` | chercher un paquet |
| `nh clean all --keep 5` | nettoyer les anciennes générations (manuel) |
| `nd` | `nix develop` en gardant zsh |
