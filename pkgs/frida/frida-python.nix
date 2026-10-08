{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-KFCjfnhN7Aubz5JavIhF93Sz32gER2KuwQGZ5U7b/FY=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-XQmKk8gL3DGreTw8GNlWSqfXJQ4JpzuAFooO/ugZWDQ=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-XQmKk8gL3DGreTw8GNlWSqfXJQ4JpzuAFooO/ugZWDQ=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-wxZyBkIIAZcngpTgXb4S870Sh4nbTgYj4NVJst2MJC4=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.23.1";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
