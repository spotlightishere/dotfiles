{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule rec {
  pname = "ipsw";
  version = "3.1.653";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-fgiOsDKd2OmsB7THC4GbCCEESWWFxznIuebjQEC40W8=";
  };

  vendorHash = "sha256-b5nhsMQzm7Mo6BIAP0Z2LCqyDhCCW1snp0gCEFdh+T0=";

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
