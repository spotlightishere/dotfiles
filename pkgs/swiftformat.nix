{ clangStdenv, lib, fetchFromGitHub, swift, swiftpm, swiftPackages }:

clangStdenv.mkDerivation rec {
  pname = "swiftformat";
  version = "0.53.5";

  src = fetchFromGitHub {
    owner = "nicklockwood";
    repo = "SwiftFormat";
    rev = version;
    sha256 = "sha256-4NdJxxoug2vuoMeAvA6T1TQ/xWYoxOPtn5rBgf4x2dI=";
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
