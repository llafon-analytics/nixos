# System modules (`modules/nixos`)

`modules/nixos/default.nix` is the base imported by every host. It imports the external NixOS
modules (Stylix, Home Manager, nix-index-database) and the following modules:

| Module | Content |
|---|---|
| `base/boot.nix` | systemd-boot (1 s), Plymouth, NTFS, inotify, v4l2loopback + `snd_aloop`, zram |
| `base/locale.nix` | Europe/Paris time zone, `en_US.UTF-8` locale, French keyboard (X11 and console) |
| `base/nix.nix` | flakes, `allowUnfree`, NVIDIA licence, channels disabled, comma |
| `base/system.nix` | polkit, rtkit, D-Bus, udisks2 |
| `base/users.nix` | zsh as default shell (users are declared per host) |
| `network.nix` | NetworkManager, Cloudflare DNS, IPv6 disabled, Tailscale, firewall policy |
| `home-manager.nix` | overlays, `useGlobalPkgs`, shared HM modules (Zen, Caelestia) |
| `desktop/` | Hyprland, hyprlock, PipeWire, fonts, Stylix, XDG portals, apps (KDE Connect, Emacs, Yazi…) |
| `desktop/keyring.nix` | gnome-keyring (Secret Service), Seahorse, `secret-tool`; KWallet-PAM disabled on `login` |
| `printing.nix` | CUPS, Avahi (mDNS), IPP-over-USB |
| `gaming/` | Steam (Millennium), Gamescope, GameMode, gaming packages, Wolf udev rules |
| `hardware/logitech.nix` | Logitech devices + Solaar |
| `packages/common.nix` | shared system packages, by domain |

Modules imported by some hosts only:

| Module | Host |
|---|---|
| `hardware/nvidia.nix` | desktop |
| `hardware/amdgpu.nix`, `hardware/tlp.nix` | laptop |
| `hardware/rtw89.nix` (TP-Link TXE70UH Wi-Fi dongle) | both |
| `gaming/gamemode-optimizations.nix` | desktop |
| `packages/{desktop,laptop}.nix` | matching host |

## Notes

- Hostname, user and `system.stateVersion` (`23.05`) are set in each host.
- The `nixpkgs` registry entry and `NIX_PATH` point at the flake's `nixpkgs` input automatically.
- Secret Service: gnome-keyring is the only `org.freedesktop.secrets` provider. SDDM autologin gives PAM no password, so the keyring is unlocked on first access in each session (gcr prompt), e.g. `secret-tool store --label=<name> service <name> kind <type>`.
