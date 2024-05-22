{ config, lib, pkgs, ... }:
let
  # In order to allow reuse of the iTerm2 shell integrations repo
  # for both its utility symlinks and zsh initialization plugin,
  # we define how to fetch it here.
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "ba089f7b6718133e1cdf03404aea2150b52f6d33";
    sha256 = "sha256-uVptkYXipqpwSnKQ/rMT8al5isjXSRC9asYQTDGFwMY=";
  };
in
{
  # Very opinionated :)
  programs.zsh = {
    enable = true;

    # We want several options:
    autocd = true;
    history = {
      ignoreAllDups = true;
      ignoreSpace = true;
      size = 5000;
    };

    # Common plugins.
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    plugins = with pkgs; [
      {
        name = "expand-multiple-dots";
        src = ../zsh/expand-multiple-dots;
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
        src = ../zsh/p10k;
        file = "p10k.zsh";
      }
    ];

    # We use powerlevel10k as our ZSH theme.
    # By using the derivation in nixpkgs, we also get gitstatusd.
    # The .p10k.zsh config is beneath.
    initExtraBeforeCompInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

    # Some custom configurations:
    initExtra = ''
      # pushd
      setopt AUTO_PUSHD

      # Per-device, flexible configuration
      # (Contrary to its name, it should not house keys.)
      if [ -f $HOME/.keysrc ]; then
        source $HOME/.keysrc
      fi

      # History search, but from beginning
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
    '';
  };

  # We'd like to have the iTerm2 shell integration utilities in ~/.iterm2.
  home.file.".iterm2".source = "${iterm2_shell_integration}/utilities";
}
