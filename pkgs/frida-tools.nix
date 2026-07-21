{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-ZhGCu6zJbWrXH57pVZJFf8g4sl+Ts4dVdzkHVffUnWU=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-0xKQQQE3pYbTMgXMW3H7IWPwniewAv6jv7Umva58HbU=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-ZNU1HAllO/YUicFozKNVulthcgFyuexZGecGNmT2wkM=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-TpRIz+H8ZFV5tVRFyjF1amZFZ4hypBPvtFA4ySMab78=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.16.3";

    src = old.src.override {
      inherit version;

      hash = wheelMetadata.hash;
      platform = wheelMetadata.platform;
    };
  });

  # Overriding this is a hassle.
  # We're going to entirely copy frida-tools.
  # https://github.com/NixOS/nixpkgs/blob/b314521edc6a41029806005d97ed11f57402ee50/pkgs/by-name/fr/frida-tools/package.nix#L4
in
pkgs.python3Packages.buildPythonApplication (finalAttrs: {
  pname = "frida-tools";
  version = "14.10.4";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit (finalAttrs) version;
    pname = "frida_tools";
    hash = "sha256-eixUS1RdCVBA//vTdoooekJjQ9rYkJW0ok9LIDgtkmo=";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
  ];

  pythonRelaxDeps = [
    "websockets"
  ];

  dependencies = with pkgs.python3Packages; [
    pygments
    prompt-toolkit
    colorama
    websockets
  ] ++ [
    # Our updated version.
    frida-python
  ];

  meta = {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers (client tools)";
    homepage = "https://www.frida.re/";
    maintainers = with pkgs.lib.maintainers; [ spotlightishere ];
    license = with pkgs.lib.licenses; [
      lgpl2Plus
      wxWindowsException31
    ];
  };
})
