{ config, lib, pkgs, ... }:

# In order to allow reuse of the iTerm2 shell integrations repo
# for both its utility symlinks and zsh initialization plugin,
# we define how to fetch it here.
let
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "6554045b1184b213fdc9d731a45e8a75858291de";
    sha256 = "yhgowvJfxVdJE1yVYPWnJYvzhMsPc+HgkmDa++CcTDo=";
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
    cloc
    croc
    ffmpeg
    go
    google-cloud-sdk
    gradle
    htop
    jdk
    jq
    mtr
    ncdu
    nixopsUnstable
    p7zip
    pry
    pwgen
    rustup
    tmux
    unar
    virt-manager
    watch
    wget
    yt-dlp
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
        name = "expand-multiple-dots";
        src = ./zsh/expand-multiple-dots;
        file = "expand-multiple-dots.zsh";
      }
      {
        name = "iterm2-shell-integration";
        src = iterm2_shell_integration;
        file = "shell_integration/zsh";
      }
      {
        # Our zsh-powerlevel10k configuration file.
        name = "p10k";
        src = ./zsh/p10k;
        file = "p10k.zsh";
      }
    ];
    
    # We use powerlevel10k as our ZSH theme.
    # By using the derivation in nixpkgs, we also get gitstatusd.
    # The .p10k.zsh config is beneath.
    initExtraBeforeCompInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
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

  # We'd like to have the iTerm2 shell integration utilities in ~/.iterm2.
  home.file.".iterm2".source = "${iterm2_shell_integration}/utilities";

  programs.zsh.initExtra = ''
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

