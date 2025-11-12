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
  version = "3.1.637";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    rev = "v${version}";
    hash = "sha256-5wo4FmYzjm68lCCtJ95EJ872IHy6HCrM+5AtMezI7tM=";
  };

  vendorHash = "sha256-0KQ0v6yDwzk69L2+xNSbuF+PGiBWrVXh91K8kEXam3I=";

  overrideModAttrs = (old: {
    # TODO: Temporary fix for 3.1.637
    preBuild = old.preBuild + ''
      go mod tidy
    '';
  });

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
