{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-bfb1HWQEO/hq1rrphmp8FYO9twvm7p5G9xIlcd4mKXA=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-3hKP4c8BWOZ5yHI55ZEAHbuTpLFH+GWBzvkG7jexiJw=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-Hq5MTLtkjOU2Qa4Cuor0y6cTR0px73NcYg/gr2Fzog0=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.3";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
