# Modules système (`modules/nixos`)

`modules/nixos/default.nix` est le socle importé par chaque host. Il importe les modules NixOS
externes (Stylix, Home Manager, nix-index-database) et les modules suivants :

| Module | Contenu |
|---|---|
| `base/boot.nix` | systemd-boot (1 s), Plymouth, NTFS, inotify, v4l2loopback + `snd_aloop`, zram |
| `base/locale.nix` | fuseau Europe/Paris, locale `en_US.UTF-8`, clavier FR (X11 et console) |
| `base/nix.nix` | flakes, `allowUnfree`, licence NVIDIA, channels désactivés, comma |
| `base/system.nix` | polkit, rtkit, D-Bus, udisks2 |
| `base/users.nix` | zsh comme shell par défaut (les utilisateurs sont déclarés par host) |
| `network.nix` | NetworkManager, DNS Cloudflare, IPv6 désactivé, Tailscale, politique de pare-feu |
| `home-manager.nix` | overlays, `useGlobalPkgs`, modules HM partagés (Zen, Caelestia) |
| `desktop/` | Hyprland, hyprlock, PipeWire, polices, Stylix, portails XDG, applis (KDE Connect, Emacs, Yazi…) |
| `desktop/keyring.nix` | gnome-keyring (Secret Service), Seahorse, `secret-tool` ; KWallet-PAM coupé sur `login` |
| `printing.nix` | CUPS, Avahi (mDNS), IPP-over-USB |
| `gaming/` | Steam (Millennium), Gamescope, GameMode, paquets gaming, règles udev Wolf |
| `hardware/logitech.nix` | périphériques Logitech + Solaar |
| `packages/common.nix` | paquets système communs, par domaine |

Modules importés seulement par certains hosts :

| Module | Host |
|---|---|
| `hardware/nvidia.nix` | desktop |
| `hardware/amdgpu.nix`, `hardware/tlp.nix` | laptop |
| `hardware/rtw89.nix` (clé Wi-Fi TP-Link TXE70UH) | les deux |
| `gaming/gamemode-optimizations.nix` | desktop |
| `packages/{desktop,laptop}.nix` | host correspondant |

## Points notables

- Hostname, utilisateur et `system.stateVersion` (`23.05`) sont définis dans chaque host.
- `nixpkgs` et `NIX_PATH` pointent automatiquement sur l'input `nixpkgs` de la flake.
- Secret Service : gnome-keyring est l'unique fournisseur `org.freedesktop.secrets`. L'autologin SDDM ne fournit pas de mot de passe à PAM : le trousseau est déverrouillé au premier accès de la session (invite gcr), p. ex. `secret-tool store --label=<nom> service <nom> kind <type>`.
