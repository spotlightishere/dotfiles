{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule rec {
  pname = "ipsw";
  version = "3.1.650";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-MHrcIUK7y0ra5FOk+fEp6yEZ9VBMu1BF0GTPOPUGxZg=";
  };

  vendorHash = "sha256-xECvPezPzhHdbym918t9nSYZu6WzuW+nn25uiF53moc=";

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
