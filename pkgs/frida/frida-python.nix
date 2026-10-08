{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-6vOEY4B2VgnGSa17rLBc6L1lmAXlxsKrdmoeKoBWio0=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-zd1pnJBLU3bsW9u3c7soKvqgi2OESAnsNjDtE0f0HrE=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-qBeLcMWIjnQNu3BwUVhGkZy3d4xABwh0QLUmUhoZMss=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-Cc5HlixfdEqX3KfeEP8mReRP9+rPBnIIi8XfzL37ikw=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.23.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
