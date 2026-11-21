{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-AQ1N1fgUV9A6NsbueaKsavQF7JmxH4CCgMTr9Lu5mAo=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-2IGadmporD9voMD5K417TgM1xfcZa1HRdl2LJc2g3u4=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-MTOzTy2Oj90rOpUkVZx6vVztR7LG0aujRfT3lU2UoyA=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.4";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
