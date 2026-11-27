{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-H7BWLK6Po+kjG6RwORyvNCueq4azf5015pumW1g32PE=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-zJChZGDaUPXZU/eGm2Tmk8ohdL+l8a1+d4SsJovhDoY=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-KlSQ7SVBxGX4BbplDuvCO0QqBsb54yj5hfDVrVNQBuE=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.5";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
