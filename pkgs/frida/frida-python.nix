{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-kQyxJoHE+GXBMvu6MmB8I6tqxq/ss4QKYLYwJUF3hXk=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-YTf/N/RlDfD6D07fT8WDDqIDTf9OOg8fN9ajN5To30U=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-x9E5OsvaXHR4DZ4XSKojuxXnolQyWbpqVVwkQ25p6+Q=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.1";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
