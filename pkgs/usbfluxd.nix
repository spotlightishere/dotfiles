{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libimobiledevice
, libusb1
, libusbmuxd
, usbmuxd
, libplist
, runCommand
, xcodebuild
,
}:
let
  # We require `ibtool` from Xcode.
  buildSymlinks = runCommand "usbfluxd-build-symlinks" { } ''
    mkdir -p $out/bin

    # We need to symlink the exact location to ibtool.
    #
    # Otherwise, `/usr/bin/ibtool` will forever invoke `xcrun`,
    # which invokes `xcrun ibtool`, which invokes `xcrun ibtool`,
    # which [...]
    unset DEVELOPER_DIR
    ibtool_path="$(/usr/bin/xcrun --sdk macosx --find ibtool)"

    # copypng requires pngcrush.
    copypng_path="$(/usr/bin/xcrun --sdk macosx --find copypng)"
    pngcrush_path="$(/usr/bin/xcrun --sdk macosx --find pngcrush)"

    ln -s "$ibtool_path" "$copypng_path" "$pngcrush_path" $out/bin
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "usbfluxd";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "corellium";
    repo = "usbfluxd";
    rev = "608cb24e08135f7b365ace7e9cfa54243838e508";
    hash = "sha256-cFaP675wvgLUke1CPGQLFGQHrujtDu4mzDLGzUaxDQE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ] ++ (lib.optionals stdenv.hostPlatform.isDarwin [
    buildSymlinks
    xcodebuild
  ]);

  buildInputs = [
    libimobiledevice
    libusb1
    libusbmuxd
    usbmuxd
    libplist
  ];

  # Taken from `macvim`:
  # https://github.com/NixOS/nixpkgs/blob/870010b06223f18b853765f3a8aa4c4ab868cadf/pkgs/applications/editors/vim/macvim.nix#L202-L210
  #
  # We rely on the user's Xcode install to build. It may be located in an arbitrary place, and
  # it's not clear what system-level components it may require, so for now we'll just allow full
  # filesystem access. This way the package still can't access the network.
  sandboxProfile = lib.optionals stdenv.hostPlatform.isDarwin ''
    (allow file-read* file-write* process-exec mach-lookup)
    ; block homebrew dependencies
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
  '';

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail 'with_static_libplist=yes' 'with_static_libplist=no'
    substituteInPlace usbfluxd/utils.h \
      --replace-fail PLIST_FORMAT_BINARY //PLIST_FORMAT_BINARY \
      --replace-fail PLIST_FORMAT_XML, NOT_PLIST_FORMAT_XML
  '';

  # On Darwin, we also want to build the GUI wrapper.
  # This must be performed after `usbfluxd` and `usbfluxctl` are built.
  postBuild = lib.optionals stdenv.hostPlatform.isDarwin ''
    export DSTROOT=$out

    # Needed or we get mysterious simulator errors:
    # https://github.com/fink/fink-distributions/issues/1115
    export DERIVED_DATA_PATH=$PWD/DerivedData

    # We set several custom options:
    # - Disable clang modules due to issues emitting `*.pcm` files for SDK frameworks
    # - Disable signing with the upstream hardcoded identity
    # - Work around no frameworks actually being specified
    xcodebuild \
      SYMROOT=$PWD/Products \
      OBJROOT=$PWD/Intermediates \
      -project USBFlux/USBFlux.xcodeproj \
      -target USBFlux \
      -configuration Release \
      -derivedDataPath "$DERIVED_DATA_PATH" \
      MACOSX_DEPLOYMENT_TARGET=${stdenv.hostPlatform.darwinMinVersion} \
      CLANG_ENABLE_MODULES=NO \
      CODE_SIGN_IDENTITY="" \
      OTHER_LDFLAGS="-framework AppKit -framework Foundation -framework Security" \
      build
  '';

  postInstall = lib.optionals stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r Products/Release/USBFlux.app $out/Applications
    rm -rf $out/USBFlux.app
  '';

  meta = {
    homepage = "https://github.com/corellium/usbfluxd";
    description = "Redirects the standard usbmuxd socket to allow connections to local and remote usbmuxd instances so remote devices appear connected locally";
    license = lib.licenses.gpl2Plus;
    mainProgram = "usbfluxctl";
    maintainers = with lib.maintainers; [ x807x ];
  };
})
