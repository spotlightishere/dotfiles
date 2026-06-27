{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule rec {
  pname = "ipsw";
  version = "3.1.700";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-dkEoQ5wUfFgXGC8N46fMu6Do7stStRrab+KmpbtZakM=";
  };

  postPatch = ''
    # These rely on Go packages that are not open-source.
    # As they import packages not present on GitHub,
    # Nix's default action of running `go mod tidy` fails.
    #
    # As of writing, these are the following:
    #    - github.com/blacktop/ipsw/pkg/sandbox
    #    - github.com/blacktop/ipsw/pkg/sandbox/normalize
    #
    # One way to detect this is the presence of the sandbox tag:
    #     `//go:build sandbox`

    rm ./internal/diff/sandbox.go
    rm ./internal/diff/sandbox_test.go
    rm ./cmd/ipsw/cmd/diff_sandbox.go
    rm ./cmd/ipsw/cmd/sb/sb_diff.go
    rm ./cmd/ipsw/cmd/sb/sb_reach.go
    rm ./cmd/ipsw/cmd/sb/sb_reach_test.go
  '';

  vendorHash = "sha256-97U+zI5L7i44ucsBOoyuCG9WZR5T7X+VFrQ3jXzu8c4=";

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
