{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-LhdeZ4M/+/AiB5ZzIUlcAb26olQZBsrc/Zg0ruKgLBQ=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-lROCrxxVO4FZaYBjDIO39K1cgRQ+3ta4NQFrq9/mM4w=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-kB066ZGP8uHZh/YAlBZBYVxE4qesB1Pp0MYq1dNWve0=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.6";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
