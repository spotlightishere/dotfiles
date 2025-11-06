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

    # TODO(spotlightishere): Fix this up, or upstream it
    pry = prev.callPackage ./pry/default.nix { };

    # TODO(spotlightishere): Similarly, upstream Frida updates.
    # Due to the length of wheel hashes, we override in a separate file.
    frida-tools = import ./frida-tools.nix { pkgs = prev; };

    # TODO: These are re-exported to assist in rebuilding
    # GNOME packages with libimobiledevice dependencies.
    geary = prev.geary;
    gnome-calendar = prev.gnome-calendar;
    gnome-session = prev.gnome-session;
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

      # Always obtain the latest Git revision.
      passthru.updateScript = prev.unstableGitUpdater { };
    });

  mobiledevicePackages = {
    # TODO: libtatsu is not yet upstream
    # https://github.com/NixOS/nixpkgs/pull/435575
    libtatsu = prev.callPackage ./libtatsu.nix { };

    libimobiledevice = updateDevicePackage {
      name = "libimobiledevice";
      rev = "149f7623c672c1fa73122c7119a12bfc0012f2ac";
      hash = "sha256-SWWsa7asCXpcz80VNhxoePWr74QY8SP0byGSCp+nGG0=";

      # We also must include libtatsu.
      buildInputs = [ final.libtatsu ];
    };

    libimobiledevice-glue = updateDevicePackage {
      name = "libimobiledevice-glue";
      rev = "077963174182b6f71f8d8d4e373482addcf4ff3d";
      hash = "sha256-5czWHRmO1VpoTLhsqTw8GGfeSvtkgJIHjlHu9icnHwQ=";
    };

    usbmuxd = updateDevicePackage {
      name = "usbmuxd";
      rev = "2efa75a0a9ca73f2a5b6ec71e5ae6cb43cdab580";
      hash = "sha256-8Dx8yN/vatD1lp3mzUUSKyx2/plv3geJhz3oQRhl7UM=";
    };

    libusbmuxd = updateDevicePackage {
      name = "libusbmuxd";
      rev = "93eb168bf6b07472d17781328c21df0c60300524";
      hash = "sha256-yQBKUrkG3WAxhmniXyJ0qnRyETwW7VkVNL2omiLXUHs=";
    };

    libirecovery = updateDevicePackage {
      name = "libirecovery";
      rev = "b59ef4814525f487287da1609864f432cd79e3ed";
      hash = "sha256-CSDG8mOLvKAIpxmZnNLMKY1HvQIqk66/rkjmzq7F8vY=";
    };

    libplist = updateDevicePackage {
      name = "libplist";
      rev = "7355dc8e8344f00fae0e24db72e461d985eb6381";
      hash = "sha256-wKqXmTc3rvRtDDcE60FmJOt6jADOpBX0MAjcxYRXOoM=";
    };

    idevicerestore = updateDevicePackage {
      name = "idevicerestore";
      rev = "f4d0f7e83105cc362527566315abee07b0840848";
      hash = "sha256-fqTVAHTxamk2lIllr7ZNHOJ1YTJHM4JpVQylMV33CJI=";

      # Similar to libimobildevice, we need libtatsu.
      buildInputs = [ final.libtatsu ];
    };

    ideviceinstaller = updateDevicePackage {
      name = "ideviceinstaller";
      rev = "baa9b5d16e1b387afebef98e96f48fc8b60332ce";
      hash = "sha256-d8jqsgidN1T4JG/ksbsxwC7e05x+hebWhtaNRY0augU=";
    };
  };
in
standalonePackages // mobiledevicePackages
)
