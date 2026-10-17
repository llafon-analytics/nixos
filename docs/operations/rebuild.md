# Rebuild

## Avec `nh` (recommandé)

`nh` connaît l'emplacement du dépôt (`~/Documents/nix-configuration`) et choisit la configuration
d'après le hostname. Il affiche l'arbre de build et le diff des paquets avant activation.

| Commande | Effet |
|---|---|
| `nh os switch` | applique immédiatement et met à jour le bootloader |
| `nh os test` | applique jusqu'au prochain redémarrage |
| `nh os boot` | applique au prochain démarrage |
| `dupdate` / `lupdate` | `nh os switch --hostname desktop` (resp. `laptop`) `--show-trace` |

!!! note "Premier rebuild après le passage aux hostnames `desktop` / `laptop`"
    Tant que la machine s'appelle encore `nixos`, utiliser `dupdate` / `lupdate` (ou
    `--hostname`), qui nomment la configuration explicitement.

## Avec `nixos-rebuild`

| Mode | Commande | Effet |
|---|---|---|
| Aperçu | `sudo nixos-rebuild dry-activate --flake .#desktop` | simulation |
| Temporaire | `sudo nixos-rebuild test --flake .#desktop` | actif jusqu'au reboot |
| Permanent | `sudo nixos-rebuild switch --flake .#desktop` | actif immédiatement |
| Boot suivant | `sudo nixos-rebuild boot --flake .#desktop` | appliqué au prochain démarrage |

Remplacez `desktop` par `laptop` selon le cas.
