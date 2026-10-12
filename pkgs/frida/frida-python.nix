{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-6orPYBPSy6DW23PUdZ/TeZh5D5KvhtNKPkmWXTkJYOk=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-0WLnDP9c91P/dJbiQDunYIJzrnt7GjRia2qhwr7nJEQ=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-FjBuUmrZFkBC44TwtIt6u/W5fUTxiSi8MN5VOpuLpOI=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-h96w9yOm57bSEbrdE6+bA81KQAYxW2nN7CRg3InWbYI=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.23.2";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
