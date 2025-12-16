{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-5ARTtnpqAp3aFnre26xAHWC7QwmsBgUpWJOT0MkwNOw=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-TFRH35GUKqzj/p129gUA2z4msD5O52dnjRE1qUX4/YQ=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-zYOenwaZPFfppCN7r/iR8eQXx1a0J3RM5aFr7XUTdKQ=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-uiINI54mZz/CxoqguKonm0iNZWyeX6dY+FEuiFX5YSw=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  # We upgrade it to 17.5.2.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.5.2";

    src = old.src.override {
      inherit version;

      hash = wheelMetadata.hash;
      platform = wheelMetadata.platform;
    };
  });
in

# Next, the wrapping frida-tools CLI.
  # We similarly want to update it.
pkgs.frida-tools.overridePythonAttrs (old: rec {
  version = "14.5.0";

  src = pkgs.fetchPypi {
    inherit version;

    pname = "frida_tools";
    hash = "sha256-Wdjx0NDGojpaycHcgXp+UiBsiAoR3V3UaWw9948HWZ0=";
  };

  # Inject our updated `frida` package.
  packageOverrides = [
    frida-python
  ];
})
