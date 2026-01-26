{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-nEUIxCe+RV7olzB4a9k4PtpyOPs9si+FwlWmZ91LxJE=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-6FRIJv7A9ZIhOxxtO4p2GFByi7BqwBEuhy0+snWATmk=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-l2PXKXZDSSoG03oPoh1D9BTDt+WNsOgVksFdNmpq23k=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-y9p41jqSFQhsfGoF2ya+DWAW9vkZ5xNdO5/7Rnk648s=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.6.2";

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
