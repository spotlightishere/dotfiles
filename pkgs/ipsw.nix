{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule rec {
  pname = "ipsw";
  version = "3.1.648";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-DrtOMJxbUFt27Ct7IsrpdR5JhBImkYAQ/A54DSTV6T0=";
  };

  vendorHash = "sha256-Nve5kOxeeV1rp3ghtPK3/E3tGdzmMDW7t0CCwPyTjiY=";

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
