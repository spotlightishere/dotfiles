{ config, lib, pkgs, specialArgs, ... }:

let
  # Whether to install desktop-targeted tools and applications.
  #
  # (This primarily focuses around macOS - please use and adopt at your own risk.)
  desktop = specialArgs.desktop or false;

  # Whether to configure various programs to leverage GPG.
  gpg = specialArgs.gpg or false;

  # It's standard convention that Darwin has the username
  # "spot" - regretfully, "spotlight" is reserved by the system.
  # (Sigh... the downsides of sharing a namesake.)
  nativeUsername =
    if pkgs.stdenv.isDarwin then
      "spot"
    else
      "spotlight";

  username = specialArgs.username or nativeUsername;
in
{
  home.username = username;

  home.homeDirectory =
    if pkgs.stdenv.isDarwin then
      "/Users/" + username
    else
      "/home/" + username;

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "Spotlight";
    userEmail = "spotlight@joscomputing.space";
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
  ++ lib.optional (desktop) ./desktop.nix
  # Configuration reliant on GPG keys being available
  ++ lib.optional (gpg) ./gpg.nix;

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

