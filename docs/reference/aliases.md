# Aliases

## Aliases partagés (`hm/zsh.nix`)

| Alias | Commande |
|---|---|
| `doom` | `~/.config/emacs/bin/doom` |
| `dupdate` | `sudo nixos-rebuild switch --flake ~/Documents/nix-configuration#desktop --show-trace` |
| `lupdate` | `sudo nixos-rebuild switch --flake ~/Documents/nix-configuration#laptop --show-trace` |
| `nd` | lance `nix develop -c zsh` pour entrer dans un dev shell Nix en gardant zsh |
| `v4l2loopback-ctl0` | config `/dev/video0` |
| `v4l2loopback-ctl1` | config `/dev/video1` |
| `skb` | switch layout clavier Hyprland |
| `extract` | `~/extract.sh` |
| `dpms` | cycle dpms Hyprland |

## direnv

Pour activer automatiquement un flake dans une repo :

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
