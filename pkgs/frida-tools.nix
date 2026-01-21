{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-CW8YHvMwZdm5qLbaMhm4L2cwWOIUhjk9AgXwPbMJ7E8=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-YzAILJobHndoatM/NmTQTUAaBiKjGXj+Oe2UHctYXBE=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-Y1uMKLesh8p4LFA2Xh8lBTMDtKGv6TepEd0sRqs+fAc=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-4TldP/xkMkHy2KgF9OYmZhU9ZBufhSRq5CZgDXktZkE=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.6.1";

    src = old.src.override {
      inherit version;

      hash = wheelMetadata.hash;
      platform = wheelMetadata.platform;
    };
  });
in

# Next, the wrapping frida-tools CLI.
pkgs.frida-tools.overridePythonAttrs (old: rec {
  version = "14.5.1";

  src = pkgs.fetchPypi {
    inherit version;

    pname = "frida_tools";
    hash = "sha256-MsIqk2fHkcQSQGhkTybVxvoKhLvdTWbtFq7w6HykxL8=";
  };

  # Inject our updated `frida` package.
  packageOverrides = [
    frida-python
  ];
})
