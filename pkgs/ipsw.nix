{ buildGo124Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.24.
# `buildGoModule` currently uses Go 1.23.
buildGo124Module rec {
  pname = "ipsw";
  version = "3.1.609";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-kPcjV2bMZAQgw0A7sDSXhNyDdjLb4IWIJxU4V/woJL0=";
  };

  vendorHash = "sha256-89URx/xDFfzO35O4GLf+NVIcOzxEEHG/Jv/d2kfvftQ=";

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
    description = "iOS/macOS Research Swiss Army Knife ";
    homepage = "https://github.com/blacktop/ipsw";
    license = lib.licenses.mit;
  };
}
