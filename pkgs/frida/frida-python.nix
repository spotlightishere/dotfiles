{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-QmFjD1WL4CLTagKWB2UDcMT1Z081yR8lsURf8u9tr70=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-iRD1yxlCCYAATJoMBjYHXiFJm00rULLYH3ev/nPzJ+Y=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-hN8noDi+4q40nVXPp0XAS8LTUMOo6j12y4BcQSxx41Y=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-AFmbhVbuCZ4ehgSFTcmE5DZ7ZR3hiEMF1qx3SuJ0SS0=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.26.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
