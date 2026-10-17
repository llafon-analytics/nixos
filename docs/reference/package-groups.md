# Groupes de paquets

`modules/nixos/packages/common.nix` range les paquets communs dans des groupes nommés.

| Groupe | Contenu |
|---|---|
| `development` | git, gh, Codex, Claude Code, nodejs, jq, clang, emacs, postman, docker-compose, conda, uv |
| `terminal` | kitty, coreutils, ripgrep, fd, fastfetch, w3m, xxd, steam-run |
| `system` | usbutils, btop, lm_sensors, mission-center, s-tui, disques, outils Wi-Fi, speedtest |
| `internet` | ungoogled-chromium, Thunderbird, Discord (+ Canary), Proton VPN/Pass, nzbget, motrix, wget |
| `office` | OnlyOffice, zathura, TeX Live, poppler, glow, pandoc, ispell, calculatrices, ledger |
| `multimedia` | OpenNOW, mpv, yt-dlp, audacity, outils PipeWire (pavucontrol, easyeffects, qpwgraph, crosspipe), GIMP, upscayl, ffmpeg |
| `android` | android-tools, scrcpy, droidcam |
| `desktop` | presse-papiers, captures d'écran, luminosité, outils X11, thème GTK Catppuccin |
| `archives` | zip, unzip, 7-Zip, unrar, atool |
| `virtualisation` | qemu |
| `fun` | pipes, cbonsai, cmatrix, cava |

## Ailleurs

- `modules/nixos/gaming/default.nix` : Lutris (stable) et les outils de jeu depuis unstable.
- `modules/nixos/packages/desktop.nix` : groupes `audio`, `video`, `virtualisation`, `benchmarks`,
  `steam`, `unstable` (`alvr`, `nvidia_oc`).
- `modules/nixos/packages/laptop.nix` : `powertop`, `radeontop`.
