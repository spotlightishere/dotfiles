{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-q8E4uhzfFyZV7P/Bft+UviaKX78z49TkXBM7p0oQ/HY=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-00gr7AWA0ynXmZrvNWphPWkkpeDOOqWIZMKe+jbeAFA=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-7d7jWTT5yueVBfIYSZoxCDHXcxjom9JP9nfzBJqxd8I=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-AmTFwqjE2huyFwabx6gWdRnymy+pPVqBvlJWzQQb3H4=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.15.3";

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
  version = "14.10.2";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit (finalAttrs) version;
    pname = "frida_tools";
    hash = "sha256-DGv5zyOkxQHXhFFrbcG4zVkNhOosymmEZdX2Aphdh/0=";
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
