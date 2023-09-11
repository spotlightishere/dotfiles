{ config, lib, pkgs, ... }:

{
  # GPG
  programs.gpg.enable = true;
  home.file.".gnupg/gpg-agent.conf" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      pinentry-program "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac"
    '';
  };

  # password-store
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };

  # Only specify signing if GPG is otherwise being pulled in;
  # i.e. in a prompt configuration.
  programs.git.signing = {
    key = "6EF6CBB6420B81DA3CCACFEA874AA355B3209BDC";
    signByDefault = true;
  };

}
