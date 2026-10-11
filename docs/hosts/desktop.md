# Host `desktop`

## Imports

- `hardware-configuration-desktop.nix`
- `nvidiagpu.nix`
- `packages/desktop.nix`
- `drivers/rtw89.nix`

## Particularités

- SSH activé sur le port `2268`.
- Docker + libvirtd + virt-manager activés.
- `vm.swappiness = 60`.
- Politique CPU NixOS normale hors jeu ; GameMode demande temporairement un profil de performance sans renice ni priorité d'E/S agressifs.
- Kernel stable de la release NixOS sélectionnée.
- SDDM + Plasma 6 + session par défaut `hyprland`.
- Home Manager utilisateur: `desktop`.
- Discord et Discord Canary patchés côté paquet Nix pour NVIDIA screen sharing.

## Mode jeu automatique

GameMode conserve une politique prudente : gouverneur et profil de performance
uniquement pendant le jeu, mitigation split-lock désactivée, sans renice, ioprio,
SCHED_ISO, pinning ni parking des cœurs. Le lancement Steam est :

```sh
gamemoderun %command%
```

Le premier client GameMode applique atomiquement un profil Hyprland sans
animations, arrondis, transparence, flou ni ombres. Il suspend Syncthing
seulement si son unité utilisateur était active, arrête les conteneurs actifs,
puis arrête `docker.service` et `docker.socket`. Le dernier client recharge la
configuration Lua déclarative et restaure exactement les services et
conteneurs mémorisés. Les états sont verrouillés et stockés séparément sous
`/run/user/$UID` et `/run/gamemode-docker`.

Discord, EasyEffects, PipeWire/WirePlumber, Kitty, btop, Steam, Caelestia (barre et
fond d'écran), Clipse, lactd, KDE Connect, Tailscale et libvirt restent actifs. Les
deux moniteurs et le VRR ne sont pas modifiés. Le direct scanout n'est pas forcé
sur ce poste NVIDIA à double écran : Hyprland 0.55.4 le prend en charge, mais ce
chemin doit être validé jeu par jeu avant d'être considéré stable ici.

Test sans jeu :

```sh
gamemoderun sleep 60
```

Diagnostic :

```sh
gamemoded -s
gamemoded -t
journalctl --user -u gamemoded
systemctl status docker.service docker.socket
docker ps --no-trunc
systemctl --user status syncthing.service
hyprctl instances
hyprctl getoption animations.enabled
hyprctl getoption decoration.blur.enabled
hyprctl getoption decoration.shadow.enabled
hyprctl getoption decoration.rounding
```

Le délai des hooks est de 120 secondes : il laisse jusqu'à 15 secondes aux
conteneurs pour s'arrêter proprement et jusqu'à 30 secondes au daemon restauré
pour redevenir disponible, tout en conservant une borne finie.

## Firewall

Les ports sont centralisés dans `hosts/desktop/ports.nix` et appliqués en TCP/UDP.
