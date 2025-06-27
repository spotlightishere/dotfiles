{ lib, buildNpmPackage, fetchzip, makeWrapper }:

buildNpmPackage rec {
  pname = "corellium-cli";
  version = "1.5.1";

  src = fetchzip {
    url = "https://registry.npmjs.org/@corellium/corellium-cli/-/corellium-cli-${version}.tgz";
    hash = "sha256-1KFBwiJKj+rpRlQZeaJGQwrbY+iBRO96xefJFou/baI=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontNpmBuild = true;

  npmFlags = [
    "--no-audit"
    "--no-fund"
    "--ignore-scripts"
  ];

  npmDepsHash = "sha256-t18JE6L8uIr7DBnfU6HigtBslFAmGyQ6TaTFd4vqG3E=";

  prePatch = ''
    # Do not use Corellium's wrapper.
    rm index.sh
    echo "hi $(pwd)"

    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  passthru.updateScript = ./update.sh;

  postInstall = ''
    wrapProgram $out/bin/corellium
  '';

  meta = {
    description = "Corellium CLI tool";
    homepage = "https://support.corellium.com/sdk/cli";
    # no license specified, leaving blank for personal ease
    mainProgram = "corellium";
  };
}
