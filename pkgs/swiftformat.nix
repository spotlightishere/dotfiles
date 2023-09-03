{ stdenv, lib, fetchFromGitHub, swift, swiftpm, swiftPackages }:

stdenv.mkDerivation rec {
  pname = "swiftformat";
  version = "0.52.3";

  src = fetchFromGitHub {
    owner = "nicklockwood";
    repo = "SwiftFormat";
    rev = version;
    sha256 = "sha256-8uok67yJaWSkSZFXk6x3TF7IwAvbJMpglarQfelMhLs=";
  };

  nativeBuildInputs = [ swift swiftpm ];
  buildInputs = [ swiftPackages.Foundation ];

  # We only install the swiftformat binary, so don't need the other products.
  swiftpmFlags = [ "--product swiftformat" ];

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
    hydraPlatforms = [];
  };
}
