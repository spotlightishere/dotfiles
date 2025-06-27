#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq nodePackages.npm nix-update

set -euo pipefail

# Obtain the latest version of this package.
version=$(npm view @corellium/corellium-cli version)
if [[ "$UPDATE_NIX_OLD_VERSION" == "$version" ]]; then
    echo "Already up to date!"
    exit 0
fi

# Extract package.json from the latest version of this package.
TMPDIR=$(mktemp -d)
tarball="corellium-cli-${version}.tgz"

curl https://registry.npmjs.org/@corellium/corellium-cli/-/"$tarball" -o "$TMPDIR"/"$tarball"
tar --strip-components=1 -xf "$TMPDIR"/"$tarball" package/package.json

# We'll need to modify its package.json.
#
# The bundled dependencies specified by @corellium/corellium-cli
# break Nix's cache as they do not include all necessary packages.
jq "del(.bundleDependencies)" package.json > package-edited.json
mv package-edited.json package.json

# Finally, update our lock file.
npm i --package-lock-only

# Clean up after ourselves.
rm -rf "$TMPDIR"

# We can now have nix-update change version and hashes.
nix-update -F corellium-cli --version "$version"
