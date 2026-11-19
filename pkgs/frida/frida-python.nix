{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-ZjsIpb+8tLF0k/FxlXRCBLTvGZzSlCmkAd5JG0/3OCA=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-btnH4eoK2TePBv1isd+u1IIIymjqW55mrD9I4WBZ4oI=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-mPgN0FyefAUggsO7TE9Y05hmTUnfC0+HoE+mFPw9Ow0=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.2";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
