{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "rtw89-firmware";
  version = "0-unstable-2026-03-05";

  # Same revision as ./rtw89.nix: the firmware must match the driver.
  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtw89";
    rev = "d2f175eafa0a4ef9cc65e7073a77e60238cae614";
    hash = "sha256-2LMbwZP+esxooSowEdV+cpOjU+Zn6KWQhEVfftMW15s=";
  };

  # The source ships a Makefile for the driver; only the firmware blobs are wanted.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/firmware
    cp -rv firmware/* $out/lib/firmware/
    runHook postInstall
  '';

  meta = {
    description = "Firmware files shipped with morrownr/rtw89";
    homepage = "https://github.com/morrownr/rtw89";
    license = lib.licenses.unfreeRedistributableFirmware;
    platforms = lib.platforms.linux;
  };
}
