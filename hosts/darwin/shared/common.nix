{ pkgs, ... }: {
  imports = [
    ./defaults.nix
    ./java.nix
  ];

  # We'd like to use Vim globally.
  environment = {
    systemPackages = [
      pkgs.vim
    ];
    variables.EDITOR = "${pkgs.vim}/bin/vim";

    etc = {
      # Ensure that the macOS-provided paths and man page paths are respected.
      # See also: https://github.com/nix-darwin/nix-darwin/issues/391
      "zprofile.local".source = ./zprofile.local;

      # Add the PCC VM tooling to our system-wide PATH.
      # https://security.apple.com/documentation/private-cloud-compute/vresetup
      "paths.d/20-vre".text = ''
        /System/Library/SecurityResearch/usr/bin
      '';

      # macOS `man` (alongside BSD `man`) is a shell script
      # that shells out to `xcode-select --show-manpaths`:
      # https://github.com/apple-oss-distributions/man/blob/248fab9b46e4f2de53e002a2c341367c1f156c9e/man/man.sh#L112-L114
      #
      # We'd rather not invoke this from a pure flake.
      # The following is from the output of `--show-manpaths` on macOS 26.0.
      # We'll assume Xcode is either Xcode.app or Xcode-Beta.app.
      "manpaths.d/10-xcode".text = ''
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man
        /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/usr/share/man
        /Applications/Xcode.app/Contents/Developer/usr/share/man
        /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man

        /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man
        /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/usr/share/man
        /Applications/Xcode-beta.app/Contents/Developer/usr/share/man
        /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man
      '';
    };
  };

  # Similarly, we'd like to use zsh.
  programs.zsh.enable = true;

  # We make the assumption our user is named `spot`.
  users.users.spot = {
    description = "Spotlight Deveaux";
    home = "/Users/spot";
    shell = pkgs.zsh;
  };
  system.primaryUser = "spot";

  nix = {
    # Keep the latest version of Nix.
    package = pkgs.nix;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";

      # Include Garnix
      substituters = [ "https://cache.garnix.io" ];
      trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    };
  };
}
