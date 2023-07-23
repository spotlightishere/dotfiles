{ stdenv, lib, fetchFromGitHub, swift, swiftpm, swiftPackages }:

# This derivation is impure: it relies on an Xcode toolchain being installed
# and available in the expected place. The values of sandboxProfile and
# hydraPlatforms are copied pretty directly from the MacVim derivation, which
# is also impure.

stdenv.mkDerivation rec {
  pname = "swiftformat";
  version = "0.51.13";

  src = fetchFromGitHub {
    owner = "nicklockwood";
    repo = "SwiftFormat";
    rev = version;
    sha256 = "sha256-8AvPA8KzejU4BI/BAX+gCjwPi4Xv0jEQbLHj9OCtasw";
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