{ config, lib, pkgs, ... }:
let
  # In order to allow reuse of the iTerm2 shell integrations repo
  # for both its utility symlinks and zsh initialization plugin,
  # we define how to fetch it here.
  iterm2_shell_integration = pkgs.fetchFromGitHub {
    owner = "gnachman";
    repo = "iTerm2-shell-integration";
    rev = "6554045b1184b213fdc9d731a45e8a75858291de";
    sha256 = "yhgowvJfxVdJE1yVYPWnJYvzhMsPc+HgkmDa++CcTDo=";
  };
in {
  # Very opinionated :)
  programs.zsh = {
    enable = true;

    # We want several options:
    autocd = true;
    history = {
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    # Common plugins.
    enableAutosuggestions = true;
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

      # History search, but from beginning
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
    '';
  };

  # We'd like to have the iTerm2 shell integration utilities in ~/.iterm2.
  home.file.".iterm2".source = "${iterm2_shell_integration}/utilities";

  # We'd also like to have Nix sourced by default within .zshenv, as
  # non-interactive shells don't always source ~/.zprofile or similar.
  programs.zsh.envExtra = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
  '';
}