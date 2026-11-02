{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-2iRbtkMWIx8pGBb59l+LpNxmxUJytgQREag5BqwoHzk=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-eaz+B7qGNPh7is6mzcsSMSratue2x6JxejiQuvilCYY=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-a635Y/17wa6Lt/CSQ5r/6r7n5MnSxYkD1bC3frntdEw=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-FctB1mxdabV4bbabk8KqQO8BcHoXnoz/XKRgi1AeI10=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.25.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
