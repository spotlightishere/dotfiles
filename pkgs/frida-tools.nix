{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-m/lgvFo96PfNh1haSnM5gP6UUPv+CIe9BCWZqDc52C8=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-hSuNrMASGWlJRkilLBz0hqZhiJanUHrvTjmloaPwI9o=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-F/mg9h8y+VflF6SSW6QcAa23OQTbrAUz2VJ8zGTcxBo=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-JzYklQc2gnXnLD9OyHqBlMTnel1cd/sjh5JagNLEwsQ=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.7.3";

    src = old.src.override {
      inherit version;

      hash = wheelMetadata.hash;
      platform = wheelMetadata.platform;
    };
  });
in

# Next, the wrapping frida-tools CLI.
pkgs.frida-tools.overridePythonAttrs (old: rec {
  version = "14.5.2";

  src = pkgs.fetchPypi {
    inherit version;

    pname = "frida_tools";
    hash = "sha256-yan13hoxurv8cUzvBW8iEmhedSOms+lTLpOmlJFbz9U=";
  };

  # Inject our updated `frida` package.
  packageOverrides = [
    frida-python
  ];
})
