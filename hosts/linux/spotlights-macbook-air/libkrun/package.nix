{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, rustPlatform
, cargo
, pkg-config
, glibc
, openssl
, libepoxy
, libdrm
, pipewire
, virglrenderer
, libkrunfw
, rustc
, withBlk ? false
, withGpu ? false
, withSound ? false
, withNet ? false
, sevVariant ? false
,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libkrun";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libkrun";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-yLpn9TpzuLstA4om/xaucoN6F4mItV2RMvjx7p/C/cs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-jsDFsjzKDzhplq+LDtIos7oCEVTznkKw9hluu+0Gw8Q=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
  ] ++ lib.optional (sevVariant || withGpu) pkg-config;

  buildInputs =
    [
      (libkrunfw.override { inherit sevVariant; })
      glibc
      glibc.static
    ]
    ++ lib.optionals withGpu [
      libepoxy
      libdrm
      # We want to override the virglrenderer input.
      # (Overriding for all of nixpkgs means that QEMU is repeatedly rebuilt.)
      # https://github.com/NixOS/nixpkgs/pull/347792#issuecomment-2667343848
      (virglrenderer.overrideAttrs
        (old: {
          src = fetchurl {
            url = "https://gitlab.freedesktop.org/asahi/virglrenderer/-/archive/asahi-20241205.2/virglrenderer-asahi-20241205.2.tar.bz2";
            hash = "sha256-mESFaB//RThS5Uts8dCRExfxT5DQ+QQgTDWBoQppU7U=";
          };
          mesonFlags = old.mesonFlags ++ [ (lib.mesonOption "drm-renderers" "asahi-experimental") ];
        }))
    ]
    ++ lib.optional withSound pipewire
    ++ lib.optional sevVariant openssl;

  makeFlags =
    [
      "PREFIX=${placeholder "out"}"
    ]
    ++ lib.optional withBlk "BLK=1"
    ++ lib.optional withGpu "GPU=1"
    ++ lib.optional withSound "SND=1"
    ++ lib.optional withNet "NET=1"
    ++ lib.optional sevVariant "SEV=1";

  postInstall = ''
    mkdir -p $dev/lib/pkgconfig
    mv $out/lib64/pkgconfig $dev/lib/pkgconfig
    mv $out/include $dev/include
  '';

  meta = with lib; {
    description = "Dynamic library providing Virtualization-based process isolation capabilities";
    homepage = "https://github.com/containers/libkrun";
    license = licenses.asl20;
    maintainers = with maintainers; [
      nickcao
      RossComputerGuy
    ];
    platforms = libkrunfw.meta.platforms;
  };
})
