{ lib
, fetchFromGitHub
, rustPlatform
, dhcpcd
, libkrun
, makeWrapper
, passt
, pkg-config
, mesa
, replaceVars
, systemd
, opengl-driver ? mesa.drivers
,
}:

rustPlatform.buildRustPackage rec {
  pname = "muvm";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = pname;
    rev = "muvm-${version}";
    hash = "sha256-vacWhCiDwcRT1fNZ0oD2b1Ei2JiZSYEk3f6Mm/2jLmI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-E6p4xVdGF/ec91SE6B981IqhTQ0pNkqWozVYcY4a+tM=";

  patches = [
    (replaceVars ./replace-udevd.patch {
      systemd-udevd = "${systemd}/lib/systemd/systemd-udevd";
    })
    ./replace-sysctl.patch
    ./run-passthru.patch
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    (libkrun.override {
      withBlk = true;
      withGpu = true;
      withNet = true;
    })
    systemd
  ];

  wrapArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        passt
        dhcpcd
      ]
    }"
  ];

  postFixup = ''
    wrapProgram $out/bin/muvm $wrapArgs \
      --set-default OPENGL_DRIVER ${opengl-driver}
  '';

  meta = {
    description = "Run programs from your system in a microVM";
    homepage = "https://github.com/AsahiLinux/muvm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = libkrun.meta.platforms;
    mainProgram = "krun";
  };
}
