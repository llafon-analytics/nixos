# Host `desktop`

## Imports (`hosts/desktop/default.nix`)

- `hardware.nix`
- `modules/nixos` (socle commun)
- `modules/nixos/hardware/nvidia.nix`, `modules/nixos/hardware/rtw89.nix`
- `modules/nixos/gaming/gamemode-optimizations.nix`
- `modules/nixos/packages/desktop.nix`
- module `nix-craftapps` (Photocraft)

## Particularités

- Hostname `desktop`, utilisateur `desktop` (seul compte déclaré).
- SSH sur le port `2268`, joignable uniquement via Tailscale.
- Docker + libvirtd + virt-manager, `nvidia-container-toolkit`.
- `vm.swappiness = 60`, TRIM hebdomadaire à travers LUKS.
- `cudaSupport` global (voir [GPU](../modules/gpu.md)).
- LACT (`lactd`) pour le monitoring/overclocking NVIDIA.
- SDDM + Plasma 6, session par défaut `hyprland`, autologin.
- Home Manager : `hosts/desktop/home.nix` (OBS avec CUDA, lazydocker, alias `valheim`, thème rofi Catppuccin).

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

Les deux scripts sont dans `scripts/gamemode/` et empaquetés par
`modules/nixos/gaming/gamemode-optimizations.nix` (`writeShellApplication`, vérifiés par shellcheck).

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

Les ports sont listés dans `hosts/desktop/ports.nix` et ouverts en TCP/UDP **sur l'interface
`tailscale0` uniquement**. Voir [Ports](../reference/ports.md).
