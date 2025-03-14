{ buildGo124Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.24.
# `buildGoModule` currently uses Go 1.23.
buildGo124Module rec {
  pname = "ipsw";
  version = "3.1.583";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-GQmI0M7+7bu/cgW7hcK5HI8+I9juhOqbBGe3vNVuOZ8=";
  };

  vendorHash = "sha256-bTZ+9uLHKRUJSAH3kHoV/YV8zp5lX2HOcWVHeXX7ypo=";

  buildInputs = with pkgs; [
    unicorn
  ];

  # Only build the `ipsw` CLI tool.
  # We do not need `ipswd`.
  subPackages = [
    "cmd/ipsw"
  ];

  ldflags = [
    "-X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=v${version}"
    # There's also `cmd.AppBuildCommit`, but this would be a hassle.
  ];

  meta = {
    description = "Simple command-line snippet manager, written in Go";
    homepage = "https://github.com/blacktop/ipsw";
    license = lib.licenses.mit;
  };
}
