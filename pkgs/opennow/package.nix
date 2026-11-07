{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "opennow";
  version = "1.0.3";

  # Upstream replaced the Electron client with a Qt rewrite in 1.0; only the
  # Qt AppImage is published for Linux.
  src = fetchurl {
    url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v${version}/OpenNOW-Qt-${version}-Linux-x64.AppImage";
    hash = "sha256-xG1Wzyk89VMhsA4Pc32e9nmbceq6wGBRhgsiK2j5EDo=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopId = "io.github.opencloudgaming.OpenNOW";
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Without a host libva the AppImage falls back to its bundled libva 1.20 and
  # Debian driver paths, which cannot load the NixOS VA-API drivers.
  extraPkgs = pkgs: [ pkgs.libva ];

  # Keep the upstream desktop file name: the app registers it with Qt, which
  # reports it as the Wayland app_id, so renaming it breaks icon matching.
  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/usr/share/applications/${desktopId}.desktop \
      $out/share/applications/${desktopId}.desktop
    substituteInPlace $out/share/applications/${desktopId}.desktop \
      --replace-fail "Exec=opennow-qt %U" "Exec=opennow %U"
    cp -a ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Open-source desktop client for GeForce NOW";
    homepage = "https://github.com/OpenCloudGaming/OpenNOW";
    changelog = "https://github.com/OpenCloudGaming/OpenNOW/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "opennow";
    platforms = [ "x86_64-linux" ];
  };
}
