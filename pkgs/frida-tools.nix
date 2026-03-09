{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-9Fp5HvOtLX7hPFzJywDtxXPNVY0jZMMMahT5cKVR/V8=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-MYZybLqM174+F3sAaBLjvrD6r92nfrXUx42360oXLSU=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-R1NKgC1HyIdbqtCNSV3FC0oFrIdlxwM638SKrBxyAwE=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-6BEyPZ3IoS9g6mNTXBl1we4Z+HLW3NHY86Fxx06gSpc=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.8.0";

    src = old.src.override {
      inherit version;

      hash = wheelMetadata.hash;
      platform = wheelMetadata.platform;
    };
  });
in

# Next, the wrapping frida-tools CLI.
pkgs.frida-tools.overridePythonAttrs (old: rec {
  version = "14.6.1";

  src = pkgs.fetchPypi {
    inherit version;

    pname = "frida_tools";
    hash = "sha256-EwpoRBHT6NyR1sHV4oEXqu5R/Wcud4n3DWxEkeZXdzM=";
  };

  # Inject our updated `frida` package.
  packageOverrides = [
    frida-python
  ];
})
