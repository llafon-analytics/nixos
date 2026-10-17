# GPU

- `modules/nixos/hardware/amdgpu.nix` (laptop): amdgpu in the initrd, RADV for Vulkan, ROCm OpenCL, 32-bit graphics.
- `modules/nixos/hardware/nvidia.nix` (desktop): open kernel module, driver
  `config.boot.kernelPackages.nvidiaPackages.production`, global `cudaSupport`. Every package that
  supports CUDA is built with it, Home Manager included; the CPU-only exceptions are temporary
  fixes (`thunderbird-onnx-cpu`, `obs-backgroundremoval-cpu`).

## Discord and Discord Canary NVENC

Both hosts install Discord and Discord Canary with Vencord through
`modules/nixos/packages/common.nix`, built by `pkgs/discord-nvenc` (patch script:
`pkgs/discord-nvenc/patch-voice-engine.py`). Both packages are wrapped so the clients start with
`/run/opengl-driver/lib` in
`LD_LIBRARY_PATH`, exposing the NVIDIA libraries needed by the screen-sharing
patch.

Both Discord packages are also patched at Nix build time, directly against the
`index.js` shipped by their current packaged versions. The
configuration does not copy the full upstream patcher `index.js`, because that
file may target a different Discord client version.

The contextual patch applies only the behavior observed in
`relativemodder/discord-linux-vulkan-video-patcher`:

- `setTransportOptions` removes `vaapi` from video experiments and adds
  `linux-nvenc` + `useCaptureDeviceForEncode` on Linux;
- `setDesktopSourceWithOptions` forces `useCaptureDeviceForEncode = true` on
  Linux;
- `createVoiceConnectionWithOptions` adds `linux-vulkan` to connection
  experiments on Linux.

Each replacement is strict: if the expected anchor is missing or appears more
than once, the build fails. In that case, inspect the new packaged
`discord_voice/index.js` and adjust the minimal patch anchors instead of copying
a complete upstream file.

`gpu_encoder_helper` and `discord_voice.node` remain executable. There is no user
service and nothing automatically mutates `~/.config/discord` or
`~/.config/discordcanary`.

### Migrating from the old user service

If the old `discord-nvenc-patch` service already ran, it may have replaced the
`~/.config/discord/*/modules/discord_voice` or
`~/.config/discordcanary/*/modules/discord_voice` symlink with a local copy. In
that case, remove the local version directory after rebuilding so Discord
recreates it from the patched Nix package:

```sh
rm -rf ~/.config/discord/0.0.* ~/.config/discordcanary/1.0.*
```

Adjust the version numbers if Discord has changed.

Chromium hardware video decoding is disabled (`--disable-accelerated-video-decode`): through
nvidia-vaapi-driver, received streams juddered. Temporary fixes `discord-nvenc-patch` and
`discord-no-vaapi-decode`.
