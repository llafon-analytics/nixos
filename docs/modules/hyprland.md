# Hyprland

## Organisation

- Base partagée : `hyprland.base.lua`
- Surcharge hôte : `wm-desktop/hyprland.lua` ou `wm-laptop/hyprland.lua`
- Liaison Nix/Home Manager: `wm-desktop/wm.nix` et `wm-laptop/wm.nix`

Les modules WM sélectionnent explicitement `configType = "lua"`. Les deux
fragments sont déployés dans `$XDG_CONFIG_HOME/hypr` via `xdg.configFile`, puis
chargés avec `require()` depuis le `hyprland.lua` généré par Home Manager.

## Outils liés

- [Caelestia](caelestia.md) : barre, notifications, launcher, verrouillage et fond
  d'écran (`hm/caelestia.nix`)
- `hyprlock` + `hypridle` (hyprlock ne sert plus que de secours)
- `rofi` réduit au sélecteur de fenêtres (`SUPER+W`)
- [Pyprland](#terminal-escamotable-pyprland) : terminal escamotable (`hm/pyprland.nix`)

## Layout scrolling

Hyprland 0.55 fournit nativement le layout `scrolling` (fenêtres en colonnes
défilant horizontalement, sans plugin). `dwindle` reste le layout par défaut.

| Raccourci | Action |
|---|---|
| `SUPER + CTRL + S` | bascule le workspace actif entre `dwindle` et `scrolling` |
| `SUPER + H/L` | colonne précédente/suivante (la fait défiler à l'écran) |
| `SUPER + K/J` | fenêtre au-dessus/en dessous dans la colonne |
| `SUPER + CTRL + H/J/K/L` | déplace la fenêtre (entre colonnes / dans la colonne) |
| `SUPER + SHIFT + H/L` | redimensionne la colonne |

La bascule ajoute une règle de workspace à l'exécution : elle est propre à
chaque workspace et disparaît au `hyprctl reload` (y compris celui du hook
GameMode) ou au redémarrage de la session. Les réglages (`column_width`, etc.)
sont dans le bloc `scrolling` de `hyprland.base.lua`.

## Terminal escamotable (Pyprland)

`SUPER + SHIFT + Entrée` affiche ou masque un terminal kitty (classe
`kitty-dropterm`) géré par le plugin `scratchpads` de Pyprland. Il est lancé au
premier appel puis conservé : la session shell et son état survivent entre deux
affichages. Il flotte au-dessus du workspace courant, quel qu'il soit, sans
retiler les autres fenêtres.

- configuration : `~/.config/pypr/config.toml`, générée par `hm/pyprland.nix`
- démon : service utilisateur `pyprland.service`, lié à `hyprland-session.target`
  (ne démarre pas sous Plasma)
- diagnostic : `systemctl --user status pyprland`, `journalctl --user -u pyprland`

## Aide-mémoire

`SUPER + F1` affiche ou masque l'aide-mémoire (raccourcis, commandes,
nouveautés), rendu par `glow` dans un second scratchpad Pyprland (`q` pour le
fermer). La source est `hm/cheatsheet.md` : la mettre à jour dans le même commit
qu'un nouveau raccourci ou outil, et y résumer les changements dans
« Nouveautés ».

Quand ce fichier change, une notification Caelestia « Nouveautés de la
configuration » s'affiche une seule fois, à l'ouverture de session suivante
(service utilisateur `cheatsheet-notify`). La version vue est mémorisée dans
`~/.local/state/nixos-cheatsheet/seen` ; supprimer ce fichier rejoue la
notification.
- script de check des règles: `scripts/check-hyprland-rules.sh`

## Validation des règles

```sh
bash scripts/check-hyprland-rules.sh
```

Ce script valide les trois fragments avec `luac -p`. Il échoue aussi si une
ancienne configuration Hyprlang contient :

- `windowrulev2` est utilisé,
- l'ancienne syntaxe de matcher est utilisée,
- `stayfocused` est utilisé au lieu de `stay_focused`.

Après la première activation de la migration :

```sh
hyprctl reload full-reset
hyprctl configerrors
```

Vérifier ensuite les écrans, l'affectation des workspaces, les raccourcis et le
fond d'écran.

Sur le desktop, les hooks GameMode utilisent `hyprctl eval` pour appliquer le
profil Lua allégé en une seule opération. Ils sélectionnent explicitement une
instance valide sans dépendre de l'environnement transmis à `gamemoded`. À la
sortie, `hyprctl reload` restaure ce fichier déclaratif. L'absence d'instance
est journalisée et n'empêche pas la gestion de Syncthing ou Docker.
