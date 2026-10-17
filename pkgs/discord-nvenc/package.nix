# Official Discord client (Vencord build) patched for NVIDIA screen sharing:
# the voice engine is forced onto NVENC/Vulkan, and Chromium's VAAPI decode is
# disabled.
{
  lib,
  writeText,
  python3,
  symlinkJoin,
  makeWrapper,
  # A discord / discord-canary derivation.
  discord,
  installDir,
  bins,
}:

let
  patchScript = writeText "discord-nvenc-patch.py" (builtins.readFile ./patch-voice-engine.py);

  patched = discord.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      voice_dir="$out/opt/${installDir}/modules/discord_voice"
      voice_index="$voice_dir/index.js"

      chmod u+w "$voice_index"
      ${python3}/bin/python3 ${patchScript} "$voice_index"
      chmod +x "$voice_dir/gpu_encoder_helper" "$voice_dir/discord_voice.node"
    '';
  });
in
symlinkJoin {
  name = "${patched.pname or "discord"}-nvenc-${patched.version or "wrapped"}";
  paths = [ patched ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    for bin in ${lib.concatStringsSep " " bins}; do
      if [ -e "$out/bin/$bin" ]; then
        # Chromium's VAAPI decode (nvidia-vaapi-driver) makes received streams judder;
        # NVENC encoding lives in discord_voice and is unaffected.
        wrapProgram "$out/bin/$bin" \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
          --add-flags "--disable-accelerated-video-decode"
      fi
    done
  '';
}
