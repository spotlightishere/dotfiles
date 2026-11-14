{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-pDhurHBS1Y3zlKMKbYCJLYJMRdvX7bFKrzJAqY6DQYQ=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-hUMtqiAg1HdUalOfwFm15i4qZOP5skkP3ieQmi4/X44=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-rio6XNpodO/YZWQjvou491xWNG74hpTb9f+cx65OrZ0=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.26.3";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
