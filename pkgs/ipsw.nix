{ buildGo123Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.23.
# `buildGoModule` currently uses Go 1.22.
buildGo123Module rec {
  pname = "ipsw";
  version = "3.1.546";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-MqF9xV57X2OlGTK7qBNGGoe/9/PHPluqYWDB9MYFcQM=";
  };

  vendorHash = "sha256-sy1wKOPfGeDgZdxDc8OcpgWSyLMc55OjWda9oj3IfSU=";

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
