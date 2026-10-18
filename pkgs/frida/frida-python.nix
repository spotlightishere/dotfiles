{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-pb93fRgs/AQrWAuyndyDURACNRJfxKuo0Pazip0IWZk=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-L9+c58LSoKhFZsm0RIwsBEy77DcbxeE7n+PSfj7DtsQ=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-CKjnqVraHnGV4vXMC1EEpSN2r1YjYCTE5LJdQlbsKbc=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-7VY/RKU6ei6l/YigQype8m41ycrMEOVKksr8IvirR4Q=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.24.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
