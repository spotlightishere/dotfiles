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

    # Note: These are re-exported to assist in rebuilding
    # GNOME packages with libimobiledevice dependencies.
    geary = prev.geary;
    gnome-control-center = prev.gnome-control-center;
    gnome-calendar = prev.gnome-calendar;
    gnome-session = prev.gnome-session;
    papers = prev.papers;
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
      rev = "da770a7687f35fbb981db4d7b47b1b032cd5c2c7";
      hash = "sha256-xIeDMn9N7GohiPoi6yZ8B5xoGWu5MkScRaNb4A8IkMY=";
    };

    usbmuxd = updateDevicePackage {
      name = "usbmuxd";
      rev = "3ded00c9985a5108cfc7591a309f9a23d57a8cba";
      hash = "sha256-0ZxEdU6LAUT0XfRk/PnRGl+r2ofttpffI8MiQljukVA=";
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
      rev = "15164ebe870590376b2286b09dc97890a07dd373";
      hash = "sha256-CUlyXsBd/9tTrKqNFTLAe0xIflD1C6HWY5Q7KBC86Lo=";
    };

    idevicerestore = updateDevicePackage {
      name = "idevicerestore";
      rev = "74e3bd9286d16fc1290abde061ee00831d5b36f8";
      hash = "sha256-e2CC+GqQ7IpnMfjRq8+8+ikSoL62CKgdbDhiaA90M+w=";

      # Similar to libimobildevice, we need libtatsu.
      buildInputs = [ final.libtatsu ];
    };

    ideviceinstaller = updateDevicePackage {
      name = "ideviceinstaller";
      rev = "1762d5f12fc590b48877aac644ba3bccb72f33f9";
      hash = "sha256-V4zJ85wF3jjBlWOY+oxo6veNeiSHVAUBipmokzhRgaI=";
    };
  };
in
standalonePackages // mobiledevicePackages
)
