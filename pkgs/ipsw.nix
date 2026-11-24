{ buildGoLatestModule, lib, fetchFromGitHub, pkgs }:

buildGoLatestModule (final: {
  pname = "ipsw";
  version = "3.1.751";

  src = fetchFromGitHub {
    owner = "blacktop";
    repo = "ipsw";
    tag = "v${final.version}";
    hash = "sha256-TZfolzxktA7N82/QaAjuijfdPlbOsHhVG1clmUx4hHw=";
  };

  # Some modules rely on Go packages that are not open-source.
  # As they import packages not present on GitHub,
  # Nix's default action of running `go mod tidy` fails.
  # As of writing, these largely involve the `sandbox` build tag.
  #
  # Upstream takes the approach of setting `proxyVendor`,
  # having Go download via its proxy instead of directly vendoring them.
  proxyVendor = true;
  vendorHash = "sha256-Rf9TSOdE0hcSCTTOFuTtXsdm7+d7oz0ocRWNvl5Z1zM=";

  buildInputs = with pkgs; [
    unicorn
  ];

  # Only build the `ipsw` CLI tool.
  # We do not need `ipswd`.
  subPackages = [
    "cmd/ipsw"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=v${final.version}"
    "-X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=${final.src.tag}"
  ];

  meta = {
    description = "iOS/macOS Research Swiss Army Knife ";
    homepage = "https://github.com/blacktop/ipsw";
    license = lib.licenses.mit;
  };
})
