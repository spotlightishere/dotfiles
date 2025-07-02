{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, curl
, libplist
, nix-update-script
,
}:

stdenv.mkDerivation rec {
  pname = "libtatsu";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libtatsu";
    rev = version;
    hash = "sha256-vf4xBTTGDJCTj4TMLOhojjAfzSbkx+ogGBnf+UeumG0=";
  };

  preAutoreconf = ''
    export RELEASE_VERSION=${version}
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [
    curl
    libplist
  ];

  outputs = [
    "out"
    "dev"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/libimobiledevice/libtatsu";
    description = "Library handling the communication with Apple's Tatsu Signing Server (TSS)";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
