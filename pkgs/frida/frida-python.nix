{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-Si7yqF1H9cHxp0nzXEti3b7gRid0JOSBkXCM1ik538U=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-aeZocf8K0YQ0RFA5eaMCmNZfeanODp3hXu1UjLtDukM=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-iB5mhAHzhEREaa5OcQRzP16KQmJEg1Yrim2ZdvmYhwk=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-6lNcnNkzQQUkqcEthEbpTHv/v2QpEecOTtLUgeFJl5k=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.24.1";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
