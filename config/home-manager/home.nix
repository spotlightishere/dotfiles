{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # TODO(spotlightishere): Is there a cleaner approach?
  home.username = if pkgs.stdenv.isDarwin then
    "spot"
  else
    "spotlight";

  home.homeDirectory = if pkgs.stdenv.isDarwin then
    "/Users/spot"
  else
    "/home/spotlight";

  home.packages = with pkgs; [
    dogdns
    go
    htop
    mtr
    ncdu
    tmux
  ];

  # Very opinionated :)
  programs.zsh = {
    enable = true;

    # We want several options:
    autocd = true;
    history = {
      ignoreDups = true;
      ignoreSpace = true;
    };

    # Common plugins.
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    plugins = with pkgs; [
      {
        name = "p10k";
        src = fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.18.0";
          sha256 = "IiMYGefF+p4bUueO/9/mJ4mHMyJYiq+67GgNdGJ6Eew=";
        };
        file = "powerlevel10k.zsh-theme";
      }
      # TODO: expand-multiple-dots.zsh should be bundled alone.
      {
        name = "exand-multiple-dots";
        src = "/home/spotlight/.dotfiles/zsh";
        file = "expand-multiple-dots.zsh";
      }
    ];
    # The .p10k.zsh config is beneath.
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs; [
      pkgs.vimPlugins.vim-airline
      pkgs.vimPlugins.vim-airline-themes
      pkgs.vimPlugins.vim-go
    ];
    settings = {
      number = true;

      # Two-spaced tabs
      tabstop = 2;
      expandtab = false;
    };
    extraConfig = ''
      set nocompatible
      filetype off
      syntax on
      filetype plugin indent on
      set backspace=indent,eol,start

      " custom filetypes
      autocmd BufNewFile,BufRead *.plist set syntax=xml

      " vim-airline
      let g:airline_powerline_fonts = 1
    '';
  };

  # We must source the p10k config.
  # TODO: We should manage the config via programs.zsh.plugins.
  home.file.".p10k.zsh".source = "/home/spotlight/.dotfiles/p10k.zsh";
  programs.zsh.initExtra = ''
    source $HOME/.p10k.zsh

    # We manually include zsh-history-substring-search.
    autoload -U history-search
    zle -N history-beginning-search-backward history-search
    zle -N history-beginning-search-forward history-search
    bindkey '^[[A' history-beginning-search-backward
    bindkey '^[[B' history-beginning-search-forward
  '';

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
