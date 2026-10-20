{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-b0muhsePjbpdDa0MHV5b0OZ88gh3pCB06YFS+iTX3f0=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-+nuhM8e6YYBz/PC2SZbqTXYdbxDI2R043TO4gzGZIU4=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-VbNSWizxJUmrK4i3IIv9O6g0q5UH6UYXUj8lLqYkeqo=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-P+ExiD+AfJWjT7DDFg0wX+U+pkwt0clHtNBga7rJG3w=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.24.2";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
