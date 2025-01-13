{ buildGo123Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.23.
# `buildGoModule` currently uses Go 1.22.
buildGo123Module rec {
  pname = "ipsw";
  version = "3.1.564";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-3jn/OvHffpgWTr0Gr4e32to7CwGs4FqemMazIKH39g8=";
  };

  vendorHash = "sha256-vrh6slrvTUAC9ht61smLq1hGMftVMrqYdx0OhUxYj+o=";

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
