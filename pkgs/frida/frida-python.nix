{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-wvrPbf4zEZQKWRpLGnsFt2HfNRV8y5VV0BSm9Xo47JI=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-+jbn1/zikzoDzj9EnAqtWCnKvBgrl0XZuasSIPrhhSI=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-SaCC+zoQWgkYX3ziWigPvftrDuQb+z5ZXkUhSe0iXsg=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-MwC19srxKL7B/mG2BzvsdlluS0qpDnZfc4MZkH7AWbA=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.26.1";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
