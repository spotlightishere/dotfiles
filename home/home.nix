{ config, lib, pkgs, specialArgs, ... }:

let
  desktop = specialArgs.desktop or false;
in {
  # It's standard convention that Darwin has the username
  # "spot" - "spotlight" was reserved by the system at some point.
  # (Sigh... the downsides of sharing a namesake.)
  home.username = if pkgs.stdenv.isDarwin then
    "spot"
  else
    "spotlight";

  home.homeDirectory = if pkgs.stdenv.isDarwin then
    "/Users/spot"
  else
    "/home/spotlight";

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    
    userName = "Spotlight";
    userEmail = "spotlight@joscomputing.space";
    # Only specify signing if GPG is otherwise being pulled in;
    # i.e. in a prompt configuration.
    signing = {
      key = "6EF6CBB6420B81DA3CCACFEA874AA355B3209BDC";
      signByDefault = true;
    };
    extraConfig = {
      color.ui = "auto";
      pull.rebase = true;
      init.defaultBranch = "main";
      blame.ignoreRevsFile = ".git-blame-ignore-revs";
    };
  };

  # Only include the desktop configuration if not dotfiles only.
  imports = [
    # vim, etc.
    ./editor.nix
    # zsh, etc.
    ./prompt.nix
  ]
  # Primarily GUI applications for desktop usage
  ++ (lib.optional (desktop) ./desktop.nix);

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

