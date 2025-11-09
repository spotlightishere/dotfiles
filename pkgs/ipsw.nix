{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:
let
  # TODO: Nixpkgs does not yet ship Go v1.25.3:
  # https://github.com/NixOS/nixpkgs/issues/456759
  # This is necessary for a dependency of `ipsw`.
  #
  # We'll just temporarily update Go to v1.25.3.
  buildGoLatestModuleReal = buildGoLatestModule.override {
    go = pkgs.go_1_25.overrideAttrs (old: {
      version = "1.25.3";
      src = pkgs.fetchurl {
        url = "https://go.dev/dl/go1.25.3.src.tar.gz";
        hash = "sha256-qBpLpZPQAV4QxR4mfeP/B8eskU38oDfZUX0ClRcJd5U=";
      };
    });
  };

in
buildGoLatestModuleReal rec {
  pname = "ipsw";
  version = "3.1.636";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-PeAQ2lMFtYBwn0DJX5MEAOv+idLZr5djzePOehJo34U=";
  };

  vendorHash = "sha256-Q61uW5KC26TIlej/m4rvT96bygVqLFJdYmBfpTNX4HQ=";

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
