{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "opennow";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v${version}/OpenNOW-v${version}-linux-x86_64.AppImage";
    hash = "sha256-Onthu6He7pjVdxUx6zgBljylIEJWecvMLHYc/5yzWlE=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/opennow-stable.desktop \
      $out/share/applications/opennow.desktop
    substituteInPlace $out/share/applications/opennow.desktop \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=opennow --no-sandbox %U"
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
