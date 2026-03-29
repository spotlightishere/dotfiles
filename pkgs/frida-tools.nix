{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-0k3yYOebo1RAT3MH3lX4Dp0NUMOTum0SVa386gjGvWI=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-pEYYOeGXaeSzt5nAU23NuxLuRuJsN6mmv5PL2W7+1xc=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-Ie1RTaVqPPa9YGSxFzNFKMndkCUSiH8/FwMqO6lqocc=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-u8VS4q+yIPKEcZA5vQYaOWSO45tYMW49dSJmV8O1dAQ=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.9.1";

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
  version = "14.8.0";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit (finalAttrs) version;
    pname = "frida_tools";
    hash = "sha256-eoq9nuva2BC/nudFVPYaq8sHNYPuHXmLf1U61RB6+TY=";
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
