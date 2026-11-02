{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-ImmYybPLedmYcROFM9LFhSXt47HqRWR8ZIPSjO2Ku3M=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-vvC8K+l9XFYNfUmcr+jd/dOQcmTU/cTZ9EArkgxVF+I=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-C4cixStXJTYK99uAXl/oLA5t2W6QmHEuLo3ZNIEEUtg=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-CQsBB7IlwYoY4u338KU9oXM46V18mQmYPMSh1WrwEB4=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.25.2";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
