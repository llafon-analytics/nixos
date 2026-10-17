{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  bc,
  nukeReferences,
}:

stdenv.mkDerivation {
  pname = "rtw89";
  version = "0-unstable-2026-03-05";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtw89";
    rev = "d2f175eafa0a4ef9cc65e7073a77e60238cae614";
    hash = "sha256-2LMbwZP+esxooSowEdV+cpOjU+Zn6KWQhEVfftMW15s=";
  };

  nativeBuildInputs = [
    bc
    nukeReferences
  ]
  ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "pic"
    "format"
  ];

  # Out-of-tree Kbuild against the selected kernel.
  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M="$PWD" modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    moddir=$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89
    mkdir -p "$moddir"
    # Core, bus (PCI/USB) and chip modules all land next to each other.
    find . -maxdepth 2 -type f -name '*.ko' -exec cp -v {} "$moddir/" \;
    nuke-refs "$moddir"/*.ko

    # Upstream asks for rtw89.conf in /etc/modprobe.d to blacklist the in-kernel driver.
    install -Dm444 rtw89.conf $out/etc/modprobe.d/rtw89.conf

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Realtek rtw89 (out-of-kernel) Wi-Fi 6/6E/7 driver bundle (morrownr)";
    homepage = "https://github.com/morrownr/rtw89";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
