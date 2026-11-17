{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-ZTIgG61uxBg4L8f9JN7dCo8rpZr9Bu/ApfBsQpuhyjI=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-9nbaiXJ9jSymh3VSLzmJ7BAQGFPeoLw8vw0XETC5y5M=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-Xh6Upf3fJuoljnnZhIQuzHCBm2oA5/oePBufBf9EYXQ=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.26.4";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
