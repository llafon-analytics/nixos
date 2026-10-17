# Hyprland

## Organisation

- Base partagée : `modules/home/hyprland/hyprland.base.lua`
- Surcharge hôte : `hosts/desktop/hyprland.lua` ou `hosts/laptop/hyprland.lua`
  (liée par `hosts/<host>/home.nix`)
- Module Home Manager : `modules/home/hyprland/default.nix` (Hyprland, rofi, kitty)

Le module sélectionne explicitement `configType = "lua"`. Les deux
fragments sont déployés dans `$XDG_CONFIG_HOME/hypr` via `xdg.configFile`, puis
chargés avec `require()` depuis le `hyprland.lua` généré par Home Manager.

## Outils liés

- [Caelestia](caelestia.md) : barre, notifications, launcher, verrouillage et fond
  d'écran (`modules/home/caelestia.nix`), y compris la mise en veille (hypridle est désactivé)
- `hyprlock` (secours uniquement)
- `rofi` réduit au sélecteur de fenêtres (`SUPER+W`)
- [Pyprland](#terminal-escamotable-pyprland) : terminal escamotable (`modules/home/pyprland.nix`)

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

- configuration : `~/.config/pypr/config.toml`, générée par `modules/home/pyprland.nix`
- démon : service utilisateur `pyprland.service`, lié à `hyprland-session.target`
  (ne démarre pas sous Plasma)
- diagnostic : `systemctl --user status pyprland`, `journalctl --user -u pyprland`

## Aide-mémoire

`SUPER + ALT + &` affiche ou masque l'aide-mémoire (raccourcis, commandes,
nouveautés), rendu par `glow` dans un second scratchpad Pyprland (`q` pour le
fermer). La source est `dotfiles/cheatsheet.md` : la mettre à jour dans le même commit
qu'un nouveau raccourci ou outil, et y résumer les changements dans
« Nouveautés ».

Quand ce fichier change, une notification Caelestia « Nouveautés de la
configuration » s'affiche une seule fois, à l'ouverture de session suivante
(service utilisateur `cheatsheet-notify`). La version vue est mémorisée dans
`~/.local/state/nixos-cheatsheet/seen` ; supprimer ce fichier rejoue la
notification.

## Documentation et ChatGPT (Pyprland)

`SUPER + ALT + é` affiche ou masque la documentation du dépôt, `SUPER + C` ChatGPT.
Les deux sont des fenêtres Chromium en mode application (`--app`), flottantes et
indépendantes du workspace, gérées par Pyprland (classes `chrome-127.0.0.1__-Default` et
`chrome-chatgpt.com__-Default`, appariement par classe car Chromium partage un
processus par profil et impose lui-même l'`app_id` à partir de l'URL).

- **Documentation** : le script `docs-scratchpad` (`modules/home/pyprland.nix`) lance
  `mkdocs serve` sur `127.0.0.1:8765` (environnement `pkgs/mkdocs-env`, partagé avec le
  devShell), attend le port, puis ouvre la fenêtre. Un verrou
  `flock` évite les doublons ; fermer la fenêtre arrête le serveur. Les
  modifications de `docs/` sont rechargées automatiquement. Échec de démarrage :
  notification + `~/.local/state/pypr-docs/mkdocs.log`. Le dépôt doit se trouver
  dans `~/Documents/nix-configuration`.
- **ChatGPT** : nixpkgs n'a pas d'application Linux (l'attribut `chatgpt` est
  l'app macOS et ne s'évalue pas sous Linux) ; l'application web tourne donc
  dans un profil Chromium dédié (`~/.local/state/pypr-chatgpt`), qui conserve la
  session. Se connecter une fois ; masquer la fenêtre ne l'arrête pas, la
  fermer puis rappeler `SUPER + C` la relance.

## Scripts liés aux raccourcis

`mute-discord` (`SUPER + ;`) et `satty-shot` (`CTRL + Impr`) sont installés comme commandes par
`modules/home/hyprland/scripts.nix` (sources dans `scripts/`), avec leurs dépendances.

## Validation

La syntaxe des trois fichiers Lua est vérifiée par le check `hyprland-lua` (en CI) :

```sh
nix build .#checks.x86_64-linux.hyprland-lua
```

Après activation d'un changement :

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
