{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-0M9k+IOkTJNT5e3nZcK6KAMAU6igd6fU8gor+ZqBCtI=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-c66sluXPtKc5Ep5+pjGsuZJsQITSeQg2oLYbesQmfzM=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-g38MdOusCcbLmfVjH1ishSr706Jb/B1mlxzD47eq2VM=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-dn67FUqJZoO3XgEeETSgjo7DH/bolo3qjRWhizeiXKw=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.24.3";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
