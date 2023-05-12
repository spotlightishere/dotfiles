{ config, pkgs, ... }:

# In order to allow reuse of the iTerm2 shell integrations repo
# for both its utility symlinks and zsh initialization plugin,
# we define how to fetch it here.
let
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "43a6dd3259be5dcdb36e733d0898924d9d8c059d";
    sha256 = "gsP72bEgNa+F9rjhLPMgzHtrrqIIFcZxPx3uDBtixp0=";
  };
in {
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
    go
    htop
    mtr
    ncdu
    tmux
  ];

  # Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    
    userName = "Spotlight";
    userEmail = "spotlight@joscomputing.space";
    signing = {
      key = "6EF6CBB6420B81DA3CCACFEA874AA355B3209BDC";
      signByDefault = true;
    };
    extraConfig = {
      color.ui = "auto";
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
  # password-store
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };

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
      {
        name = "expand-multiple-dots";
        src = "${config.home.homeDirectory}/.dotfiles/zsh/expand-multiple-dots";
        file = "expand-multiple-dots.zsh";
      }
      {
        name = "iterm2-shell-integration";
        src = iterm2_shell_integration;
        file = "shell_integration/zsh";
      }
    ];
    # The .p10k.zsh config is beneath.
  };

  programs.vim = {
    enable = true;
    # Let's not grab _all_ of Vim.
    packageConfigurable = pkgs.vim;
    plugins = with pkgs; [
      pkgs.vimPlugins.vim-airline
      pkgs.vimPlugins.vim-airline-themes
      pkgs.vimPlugins.vim-go
    ];

    settings = {
      number = true;

      # Two-spaced tabs
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    extraConfig = ''
      syntax on
      filetype plugin indent on
      set backspace=indent,eol,start

      " assistance with space-oriented tabs
      set softtabstop=2
      set smarttab

      " custom filetypes
      autocmd BufNewFile,BufRead *.plist set syntax=xml

      " vim-airline
      let g:airline_powerline_fonts = 1
    '';
  };

  # We must source the p10k config.
  # TODO: We should manage the config via programs.zsh.plugins.
  home.file.".p10k.zsh".source = "${config.home.homeDirectory}/.dotfiles/p10k.zsh";
  # We'd also like to have the iTerm2 shell integration utilities in ~/.iterm2.
  home.file.".iterm2".source = "${iterm2_shell_integration}/utilities";
  programs.zsh.initExtra = ''
    source $HOME/.p10k.zsh

    # pushd
    setopt AUTO_PUSHD

    # History search, but from beginning
    bindkey "^[[A" history-beginning-search-backward
    bindkey "^[[B" history-beginning-search-forward
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

