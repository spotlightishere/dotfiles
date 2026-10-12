{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-6e1VVdFfpajcFon7ghb+x63hpA/3vV1YOMJqPvCX7Ec=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-gAiSxLYxWuqAfs82FplmulzxsxBWKeJVHiWGqbgB1rE=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-FK3tH7z8C5zs7GK5GQ1B5VjphS0RKMx+JuBz2lZGtg8=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-UaY7owWhEuzuHSGkaphwAfr7vM/M91qBZy3nBpu+iRc=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.23.3";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
