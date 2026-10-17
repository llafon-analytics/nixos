# GPU

## `modules/nixos/hardware/amdgpu.nix` (laptop)

- Charge `amdgpu` en initrd.
- Définit `services.xserver.videoDrivers = [ "amdgpu" ]`.
- Active la stack graphics 32 bits.
- Ajoute des composants Vulkan/ROCm.

## `modules/nixos/hardware/nvidia.nix` (desktop)

- Active `cudaSupport`.
- Définit `services.xserver.videoDrivers = [ "nvidia" ]`.
- `hardware.nvidia.open = true`.
- Pilote : `config.boot.kernelPackages.nvidiaPackages.production` (branche production de nixpkgs).
- `cudaSupport` est global : tout paquet qui le supporte est construit avec CUDA, y compris côté
  Home Manager. Les exceptions CPU sont des fix temporaires (`thunderbird-onnx-cpu`,
  `obs-backgroundremoval-cpu`).

## Discord et Discord Canary NVENC

Les deux hosts installent Discord et Discord Canary avec Vencord via
`modules/nixos/packages/common.nix`, construits par `pkgs/discord-nvenc` (script de patch :
`pkgs/discord-nvenc/patch-voice-engine.py`). Les paquets sont enveloppés pour lancer les clients avec
`/run/opengl-driver/lib` dans
`LD_LIBRARY_PATH`, ce qui expose les bibliothèques NVIDIA attendues par le patch
de partage d'écran.

Les deux paquets sont aussi patchés au build Nix, directement sur leur
`index.js` livré par la version courante. La configuration ne
copie pas le `index.js` complet du patcher upstream, car ce fichier peut viser
une autre version du client Discord.

Le patch contextuel applique uniquement les changements nécessaires observés
dans `relativemodder/discord-linux-vulkan-video-patcher`:

- `setTransportOptions` retire `vaapi` des expériences vidéo et ajoute
  `linux-nvenc` + `useCaptureDeviceForEncode` sous Linux;
- `setDesktopSourceWithOptions` force `useCaptureDeviceForEncode = true` sous
  Linux;
- `createVoiceConnectionWithOptions` ajoute `linux-vulkan` aux expériences de
  connexion sous Linux.

Chaque remplacement est strict: si l'ancre attendue est absente ou apparaît plus
d'une fois, le build échoue. Il faut alors inspecter le nouveau
`discord_voice/index.js` packagé et adapter les ancres du patch minimal, plutôt
que copier un fichier upstream complet.

Les binaires `gpu_encoder_helper` et `discord_voice.node` restent exécutables. Il
n'y a pas de service utilisateur et rien ne modifie automatiquement `~/.config/discord`
ou `~/.config/discordcanary`.

### Migration depuis l'ancien service utilisateur

Si l'ancien service `discord-nvenc-patch` a déjà tourné, il a pu remplacer le
lien `~/.config/discord/*/modules/discord_voice` ou
`~/.config/discordcanary/*/modules/discord_voice` par une copie locale. Dans ce
cas, supprimer le dossier de version local après le rebuild pour laisser Discord
le recréer depuis le paquet Nix patché:

```sh
rm -rf ~/.config/discord/0.0.* ~/.config/discordcanary/1.0.*
```

Adapter les numéros si Discord a changé de version.

Le décodage vidéo matériel de Chromium est désactivé (`--disable-accelerated-video-decode`) : via
nvidia-vaapi-driver, les streams reçus saccadaient. Fix temporaires `discord-nvenc-patch` et
`discord-no-vaapi-decode`.
