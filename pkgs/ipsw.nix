{ buildGo124Module, lib, fetchFromGitHub, pkgs }:

# As of writing, this requires Go 1.24.
# `buildGoModule` currently uses Go 1.23.
buildGo124Module rec {
  pname = "ipsw";
  version = "3.1.630";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-iVkJOs5ZVD/tSH/3boUx21Lxj+j33JH3ME9ZyAf+hVU=";
  };

  vendorHash = "sha256-X0CDWg/eohwL3ct7HFN40FAPHmEiWxG3lmi380/nexY=";

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
