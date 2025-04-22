{ buildGo124Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.24.
# `buildGoModule` currently uses Go 1.23.
buildGo124Module rec {
  pname = "ipsw";
  version = "3.1.595";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-EdJfYUCTGTjcnL9XhwYaTX8T2ZTJph9JtWaBznSqbGM=";
  };

  vendorHash = "sha256-d+C6AAj39MBMpBBpKap63x06ZEpHqt1odpwbPzwklVg=";

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
