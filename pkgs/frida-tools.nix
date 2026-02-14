{ pkgs }:
let

  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-cdrMrQGUHQ8xn4phEVXDwVhyNlsUbuInMY3h9ajfwVU=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-nYKlEpJIpdE9genECjj3lP2W9Dtcvm1gqkERs/0sI0k=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-S9M5naXOE6L2t7sOCLjmwpUeFgoQIMCernR8SC0C1lQ=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-5hiXwbfyt8DS5XrmfpydEq7rrDzEee09Gr63EUeqU10=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
  frida-python = pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
    version = "17.7.2";

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
