{
  stdenvNoCC,
  fetchurl,
  lib,
}:

stdenvNoCC.mkDerivation rec {
  pname = "steaminputdb-buddy";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/Alia5/steaminputdb.com/releases/download/v${version}/steaminputdb-buddy-linux-amd64";
    hash = "sha256-ovtYOZ7lYCgx11v15I9BgpSTF9LVAwDGF7W/2WZLmcM=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 $src $out/bin/steaminputdb-buddy
  '';

  meta = {
    description = "Buddy app for SteamInputDB.com — Steam client integration for browsing/applying community SteamInput configs";
    homepage = "https://www.steaminputdb.com";
    changelog = "https://github.com/Alia5/steaminputdb.com/releases/tag/v${version}";
    license = lib.licenses.agpl3Plus;
    mainProgram = "steaminputdb-buddy";
    platforms = [ "x86_64-linux" ];
  };
}
