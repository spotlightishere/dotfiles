{ lib
, pkgs
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, openssl
, libgcrypt
, libplist
, libtasn1
, libusbmuxd
, libimobiledevice-glue
, unstableGitUpdater
,
}:

stdenv.mkDerivation rec {
  pname = "libimobiledevice";
  version = "2025-07-01";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libimobiledevice";
    rev = "cb34a171994562a78da7ea14b801759747d0fdf7";
    hash = "sha256-lwunGrIpENVlWk6XfUD3b1KihA1+NyfvB7OO0kdE1+o=";
  };

  preAutoreconf = ''
    export RELEASE_VERSION=${version}
  '';

  configureFlags = [ "--without-cython" ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [
    openssl
    libgcrypt
    libplist
    libtasn1
    libusbmuxd
    libimobiledevice-glue
    (pkgs.callPackage ./libtatsu.nix { })
  ];

  outputs = [
    "out"
    "dev"
  ];

  enableParallelBuilding = true;

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/libimobiledevice/libimobiledevice";
    description = "Software library that talks the protocols to support iPhone®, iPod Touch® and iPad® devices on Linux";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ RossComputerGuy ];
  };
}
