# Aliases

## Aliases partagés (`modules/home/zsh.nix`)

| Alias | Commande |
|---|---|
| `doom` | `~/.config/emacs/bin/doom` |
| `dupdate` | `nh os switch --hostname desktop --show-trace` |
| `lupdate` | `nh os switch --hostname laptop --show-trace` |
| `nd` | lance `nix develop -c zsh` pour entrer dans un dev shell Nix en gardant zsh |
| `v4l2loopback-ctl0` | caméra virtuelle `/dev/video0` en YU12 1280x720 @ 60 i/s |
| `v4l2loopback-ctl1` | idem pour `/dev/video1` |
| `skb` | switch layout clavier Hyprland |
| `extract` | `~/extract.sh` |
| `dpms` | cycle dpms Hyprland |

## Outils en ligne de commande (`modules/home/cli-tools.nix`)

| Commande | Rôle |
|---|---|
| `Ctrl+R` | recherche dans l'historique Atuin (Entrée remet la commande dans le prompt) |
| `z <motif>` / `zi` | saut vers un répertoire fréquent (zoxide) / sélection interactive fzf |
| `lg` | Lazygit ; à la sortie, le shell suit le dépôt ouvert |
| `lazydocker` | conteneurs Docker (desktop uniquement) |
| `nh os switch` | rebuild de l'hôte courant (`NH_OS_FLAKE` pointe sur `~/Documents/nix-configuration`, la configuration suit le hostname) |
| `nh os test` / `nh os boot` | équivalents de `nixos-rebuild test` / `boot` |
| `nh clean all --keep 5` | ménage manuel des générations et du store (aucun nettoyage automatique) |
| `nh search <motif>` | recherche dans nixpkgs |
| `, <commande>` | lance une commande de nixpkgs sans l'installer (comma) |
| `temp-fixes` | registre des fix temporaires (voir [Fix temporaires](temp-fixes.md)) |
| `mute-discord` | coupe/rétablit Discord dans PipeWire (`SUPER + ;`) |
| `satty-shot` | capture de zone annotée avec satty (`CTRL + Impr`) |

`nh` intègre nix-output-monitor (arbre de build) et affiche le diff de paquets
avant activation ; nom n'est donc pas installé séparément. Repli sans nh :
`sudo nixos-rebuild switch --flake ~/Documents/nix-configuration#desktop`.

Atuin reste local : pas de synchronisation, pas de vérification de mise à jour,
intégration IA désactivée. La flèche haut garde l'historique zsh natif. Pour
importer l'historique zsh existant (une seule fois) : `atuin import auto`.

Une commande inconnue propose le paquet nixpkgs qui la fournit (nix-index,
base pré-construite de `nix-index-database`).

## direnv

Le dépôt fournit un `.envrc` (`use flake`) : `direnv allow` charge le devShell. Pour un autre dépôt :

```sh
echo "use flake" > .envrc
direnv allow
```

## Aliases spécifiques host

| Host | Alias | Commande |
|---|---|---|
| desktop | `valheim` | lance Valheim avec gamemoderun/mangohud |
| laptop | `ac` | `sudo tlp ac` |
| laptop | `bat` | `sudo tlp start` |
