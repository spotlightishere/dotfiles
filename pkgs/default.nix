(final: prev:
let
  # First, define our standalone packages.
  # These do not require any sort of overriding whatsoever.
  standalonePackages = {
    ipsw = prev.callPackage ./ipsw.nix { };
    monaco-powerline = prev.callPackage ./monaco-powerline/default.nix { };
    telnet = prev.callPackage ./telnet.nix { };
    corellium-cli = prev.callPackage ./corellium-cli/default.nix { };
    usbfluxd = prev.callPackage ./usbfluxd.nix { };
  };

  # Secondly, we wish to upgrade several libimobiledevice packages.
  # These are all fetched from the same GitHub organization.
  #
  # We define updateDevicePackage to assist brevity.
  # `buildInputs` is an optional parameter that
  # will append to the existing nativeBuildInputs.
  updateDevicePackage = { name, rev, hash, buildInputs ? [ ] }:
    prev.${name}.overrideAttrs (old: {
      version = rev;
      src = prev.fetchFromGitHub {
        owner = "libimobiledevice";
        repo = name;
        rev = rev;
        hash = hash;
      };

      # No patches should be necessary.
      patches = [ ];
      nativeBuildInputs = old.nativeBuildInputs ++ buildInputs;
    });

  mobiledevicePackages = {
    libtatsu = prev.callPackage ./libtatsu.nix { };

    libimobiledevice = updateDevicePackage {
      name = "libimobiledevice";
      rev = "cb34a171994562a78da7ea14b801759747d0fdf7";
      hash = "sha256-lwunGrIpENVlWk6XfUD3b1KihA1+NyfvB7OO0kdE1+o=";

      # We also must include libtatsu.
      buildInputs = [ final.libtatsu ];
    };

    libimobiledevice-glue = updateDevicePackage {
      name = "libimobiledevice-glue";
      rev = "4d527c7ce24dc0a3b96cfba5fc21ed9cc6cd539b";
      hash = "sha256-qW+bORyVzAlzAaplOryU+TM4G1a9WljKFDx6bIdGz5c=";
    };

    usbmuxd = updateDevicePackage {
      name = "usbmuxd";
      rev = "523f7004dce885fe38b4f80e34a8f76dc8ea98b5";
      hash = "sha256-U8SK1n1fLjYqlzAH2eU4MLBIM+QMAt35sEbY9EVGrfQ=";
    };

    libusbmuxd = updateDevicePackage {
      name = "libusbmuxd";
      rev = "adf9c22b9010490e4b55eaeb14731991db1c172c";
      hash = "sha256-o1EFY/cv+pQrGexvPOwMs5mz9KRcffnloXCQXMzbmDY=";
    };

    libirecovery = (updateDevicePackage {
      name = "libirecovery";
      rev = "638056a593b3254d05f2960fab836bace10ff105";
      hash = "sha256-loIbNSbwiVE8/jDVIbCVReV7ZkEOxIC7g8zPaSbOA3E=";
    }).overrideAttrs(old: {
        # https://github.com/NixOS/nixpkgs/pull/419291/files
        configureFlags = [
        "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
        ''--with-udevrule=OWNER="root",GROUP="myusergroup",MODE="0660"''
      ];
    });

    libplist = updateDevicePackage {
      name = "libplist";
      rev = "cf5897a71ea412ea2aeb1e2f6b5ea74d4fabfd8c";
      hash = "sha256-Rc1KwJR+Pb2lN8019q5ywERrR7WA2LuLRiEvNsZSxXc=";
    };

    idevicerestore = updateDevicePackage {
      name = "idevicerestore";
      rev = "038a49362570ac56bae330fda8a30635134fc509";
      hash = "sha256-JIhYKWiyIQ3f/DYskdiuRebvQQa4gJvfI2Un1dGvSB0=";

      # Similar to libimobildevice, we need libtatsu.
      buildInputs = [ final.libtatsu ];
    };

    ideviceinstaller = updateDevicePackage {
      name = "ideviceinstaller";
      rev = "5bdc4dcda97bee0a304609fbab54e71489243253";
      hash = "sha256-nP4LhF0K+ja57pL3DaGrU0vXfSYByHWfamFwH67l8xc=";
    };
  };
in
standalonePackages // mobiledevicePackages
)
