{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-7gyS4Ff+aKxNCHgtpQRg7sphAm1ZuaUHLHBjdYxwTpk=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-iFEyfqMxSVDinnyExUNEt/rYs6mdAD1vmi4wyQ5QHpg=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-2pxaX0Wkvtujl7lt6RNl5zRCFSPz+f6E3ALFl2KhGA8=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-S7Fo2PvacmosIZhvb825t3nMOMmITFh8rAdBG15iHeg=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.25.1";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
