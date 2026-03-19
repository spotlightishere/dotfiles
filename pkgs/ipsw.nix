{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule rec {
  pname = "ipsw";
  version = "3.1.665";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-Oxf+hpNo/Li/S0kVjekp2RArGrYQP7voNBSTz3/Gr+Q=";
  };

  vendorHash = "sha256-rzOw51n8G9H5Sxr2rCevrmG6z2SqKZOjluYwJzYiY70=";

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
