# Package groups

`modules/nixos/packages/common.nix` sorts the shared packages into named groups.

| Group | Content |
|---|---|
| `development` | git, gh, Codex, Claude Code, nodejs, jq, clang, emacs, postman, docker-compose, conda, uv |
| `terminal` | kitty, coreutils, ripgrep, fd, fastfetch, w3m, xxd, steam-run |
| `system` | usbutils, btop, lm_sensors, mission-center, s-tui, disk tools, Wi-Fi tools, speedtest |
| `internet` | ungoogled-chromium, Thunderbird, Discord (+ Canary), Proton VPN/Pass, nzbget, motrix, wget |
| `office` | OnlyOffice, zathura, TeX Live, poppler, glow, pandoc, ispell, calculators, ledger |
| `multimedia` | OpenNOW, mpv, yt-dlp, audacity, PipeWire tools (pavucontrol, easyeffects, qpwgraph, crosspipe), GIMP, upscayl, ffmpeg |
| `android` | android-tools, scrcpy, droidcam |
| `desktop` | clipboard, screenshots, brightness, X11 tools, Catppuccin GTK theme |
| `archives` | zip, unzip, 7-Zip, unrar, atool |
| `virtualisation` | qemu |
| `fun` | pipes, cbonsai, cmatrix, cava |

## Elsewhere

- `modules/nixos/gaming/default.nix`: Lutris (stable) and the gaming tools from unstable.
- `modules/nixos/packages/desktop.nix`: `audio`, `video`, `virtualisation`, `benchmarks`, `steam`,
  `unstable` (`alvr`, `nvidia_oc`) groups.
- `modules/nixos/packages/laptop.nix`: `powertop`, `radeontop`.
