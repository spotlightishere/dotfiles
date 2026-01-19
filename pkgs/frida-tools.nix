{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-CibyI85qI9i1J+JnIlp4qI6ydJ1kqxA71NxGGMtWVcs=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-oZi+rvo4RyggCvCD9Lehex7dcJWGHj6EKBUK1E+lWMA=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-0D03kvgHrZoovX+/PgN/inzL5M/a2fQ+o+hsES+uQd4=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-cLN6HdC15zYvxP+qv0O23npEJfQgIZwG0hh5kbko2+Y=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.6.0";

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
