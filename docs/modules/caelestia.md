# Caelestia

[Caelestia Shell](https://github.com/caelestia-dots/shell) remplace HyprPanel, qui
n'est plus maintenu. C'est un shell Quickshell/QML pour Hyprland qui fournit la barre,
les notifications, le launcher, le verrouillage et le fond d'écran.

## Câblage

| Emplacement | Rôle |
|---|---|
| `flake.nix` | input `caelestia-shell`, avec `inputs.nixpkgs.follows = "nixpkgs-unstable"` |
| `common-modules.nix` | `inputs.caelestia-shell.homeManagerModules.default` dans `home-manager.sharedModules` |
| `hm/caelestia.nix` | module partagé, importé par `home-desktop.nix` et `home-laptop.nix` |

Le `follows` pointe sur `nixpkgs-unstable` et non sur `nixpkgs` : Caelestia se
construit sur `quickshell` (git), qui suit nixos-unstable. Le forcer sur la 26.05
stable est le principal risque de casse au build.

Le shell est lancé par son service systemd utilisateur (`programs.caelestia.systemd`),
rattaché à `graphical-session.target` — il n'y a donc pas d'`exec-once` dans
`hyprland.base.lua`.

## Thème

Caelestia embarque un schéma `catppuccin` avec ses quatre variantes. On épingle
`catppuccin` / `latte` / mode `light` (Latte n'existe qu'en clair) pour rester aligné
sur Stylix.

Le schéma est un état runtime (`~/.local/state/caelestia/scheme.json`) dont les
couleurs sont calculées par le CLI, pas un fichier déclaratif. Il est donc réappliqué
à chaque activation Home Manager :

```sh
caelestia scheme set -n catppuccin -f latte -m light
```

!!! warning "Cohabitation avec Stylix"
    Laissé à ses valeurs par défaut, le CLI Caelestia réécrit `gtk.css`, les couleurs
    Hyprland, `btop.conf` et les séquences de couleurs du terminal à **chaque**
    changement de schéma — ce qui entre en collision avec les symlinks en lecture seule
    de Stylix. Tous les `cli.settings.theme.enable*` sont donc à `false` dans
    `hm/caelestia.nix` : Caelestia ne théme que sa propre interface.

    Contrôle de non-régression : `~/.config/gtk-3.0/gtk.css` et `~/.config/btop/btop.conf`
    doivent rester des symlinks vers `/nix/store`. Si l'un est devenu un fichier normal,
    c'est qu'un `enable*` a été oublié.

## Raccourcis

| Raccourci | Action |
|---|---|
| `SUPER + space` | launcher |
| `SUPER + M` | dashboard |
| `SUPER + B` | sidebar (notifications) |
| `SUPER + X` | verrouillage |
| `SUPER + W` | sélecteur de fenêtres — **rofi**, Caelestia n'a pas d'équivalent |

Les touches volume/luminosité restent sur `pamixer` / `brightnessctl` ; Caelestia
affiche son OSD par-dessus.

## Verrouillage

`hypridle.conf` utilise :

```
lock_cmd = if systemctl --user is-active --quiet caelestia; then caelestia shell lock lock; elif ! pidof hyprlock >/dev/null; then hyprlock; fi
```

Le verrou de Caelestia vit dans le process du shell : si celui-ci n'est pas lancé, la
session ne doit pas rester déverrouillée, d'où le repli sur hyprlock (conservé, ainsi
que `hm/hyprlock/`).

!!! danger "Ne pas lancer hyprlock pendant que Caelestia tourne"
    Bug amont connu ([shell#988](https://github.com/caelestia-dots/shell/issues/988)) :
    hyprlock fait crasher le shell. D'où le test explicite sur le service systemd plutôt
    qu'un simple `caelestia ... || hyprlock` : un code de retour non nul de Caelestia ne
    doit jamais déclencher hyprlock pendant que le shell tourne.

Caelestia utilise son propre `pam.d/passwd` (`pam_faillock` + `pam_unix`) via
`pam_start_confdir`, sans passer par `/etc/pam.d`. Si le déverrouillage échoue,
ajouter `security.pam.services.caelestia = {};` dans `configuration.nix`.

## Fond d'écran

`paths.wallpaperDir` pointe sur `~/Pictures/Wallpapers`, alimenté par `home.file`
depuis `hm/wallpaper/`. Sélection initiale, une fois la session lancée :

```sh
caelestia wallpaper -f ~/Pictures/Wallpapers/wall3.png
caelestia shell wallpaper get
```

Le choix est ensuite persisté dans l'état de Caelestia et modifiable via le launcher.

## Réglages

`programs.caelestia.settings` est volontairement minimal. Les clés amont
(`bar.*`, `services.gpuType`, `bar.statusIcons`, `appearance.*`) ne sont pas
documentées de façon stable et **une clé inconnue est ignorée silencieusement**.
Ne pas les deviner : lire les valeurs effectives après un premier lancement, puis
n'ajouter que ce qui est réellement voulu.

```sh
caelestia shell -s          # liste les cibles IPC
caelestia shell drawers list
caelestia scheme get
systemctl --user status caelestia
journalctl --user -u caelestia -e
```
