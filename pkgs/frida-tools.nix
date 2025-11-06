{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-gUYHLjKLoUI/aXzB+aU5yvfmObcA9hctkBqLgZxHvi0=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-zU9mmxU8WWs2dG3lHnSiY0oTDN2tUFTMolV22SHtBbc=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-hgsUQHS/DCVXSMm8ViC4zd/UVvEqYH7uwedv4ag48Mc=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-HgjAVeACzWis0WFgf/D40GAqMbqSmZ8XBilgID3Yk5A=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  # We upgrade it to 17.5.1.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.5.1";
    
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
