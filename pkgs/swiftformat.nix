{ clangStdenv, lib, fetchFromGitHub, swift, swiftpm, swiftPackages }:

swiftPackages.stdenv.mkDerivation rec {
  pname = "swiftformat";
  version = "0.56.3";

  src = fetchFromGitHub {
    owner = "nicklockwood";
    repo = "SwiftFormat";
    rev = version;
    sha256 = "sha256-ZPz/AAAs8L0Zn4jWbbCz2y0dVE8Ap1U16rVpxwQYUPI=";
  };

  nativeBuildInputs = [ swift swiftpm ];
  buildInputs = [ swiftPackages.Dispatch swiftPackages.Foundation ];

  installPhase = ''
    binPath="$(swiftpmBinPath)"
    mkdir -p $out/bin
    cp $binPath/swiftformat $out/bin/
  '';

  meta = with lib; {
    description = "A code formatting and linting tool for Swift";
    homepage = "https://github.com/nicklockwood/SwiftFormat";
    license = licenses.mit;
    maintainers = [ maintainers.bdesham ];
    platforms = with lib.platforms; linux ++ darwin;
    hydraPlatforms = [ ];
  };
}
