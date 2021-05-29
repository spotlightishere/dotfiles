load_plugin() {
  source ~/.zsh/$1/$1.plugin.zsh
}

# Things that modify
load_plugin "zsh-autosuggestions"
load_plugin "zsh-completions"
load_plugin "zsh-history-substring-search"
load_plugin "zsh-syntax-highlighting"

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
# Preserve opacity
# See: https://github.com/zsh-users/zsh-autosuggestions/issues/431#issuecomment-502329696
# Will most likely need removal at a point.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(${(@)ZSH_AUTOSUGGEST_IGNORE_WIDGETS:#zle-\*} zle-\^line-init)

source $HOME/.zsh/expand-multiple-dots.zsh # cd .../.../<tab>?
setopt prompt_subst # Make sure prompt is able to be generated properly.
setopt auto_cd # Get that ~ in here.
setopt hist_ignore_all_dups # Goodbye, random duplicates.
setopt hist_ignore_space # ' ' more like ._.
setopt inc_append_history # Write it asap
setopt share_history # goodbye, out-of-sync cross-shell passwords
setopt auto_list # magic and things involving listing of items
setopt auto_menu # Use a menu because I'm _that_ type of person

source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

#########
# the env _essentials_
#########

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=5000
export SAVEHIST=$HISTSIZE
export PATH="${HOME}/bin:$PATH"
export GPG_TTY=$(tty)

# Android SDK
if [ -d ${HOME}/bin/android-sdk ]; then
  export PATH="${HOME}/bin/android-sdk/platform-tools:${PATH}"
fi

# Go
if [ -d ${HOME}/go ]; then
  export GOPATH=${HOME}/go
  export PATH=${GOPATH}/bin:${PATH}
fi

# theos
if [ -d ${HOME}/.theos ]; then
  export THEOS=${HOME}/.theos
  export PATH=${THEOS}/bin:$PATH
fi

# devkitPro and the like
if [ -d /opt/devkitpro ]; then
  export DEVKITPRO=/opt/devkitpro
  export DEVKITARM=/opt/devkitpro/devkitARM
  export DEVKITPPC=/opt/devkitpro/devkitPPC
  export PATH=/opt/devkitpro/tools/bin:$PATH
fi

if [[ $OSTYPE == darwin* ]]; then
  # Under x86_64, we assume brew is in /usr/local.
  # However, under arm64e, it may be under /opt/homebrew.
  # Alternatively, the user may not have Homebrew installed
  # whatsoever, in which nothing needs to be done.
  # (By user, I mean me, and the occasional VM.)
  if [ -f /usr/local/bin/brew ]; then
    BREW_PREFIX="/usr/local"
    BREW_FOUND=true
  elif [ -f /opt/homebrew/bin/brew ]; then
    BREW_PREFIX="/opt/homebrew"
    BREW_FOUND=true
  else
    BREW_FOUND=false
  fi

  if $BREW_FOUND; then
    # Ensure Homebrew can be found within the path.
    export PATH="${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:${PATH}"
    export FPATH="${BREW_PREFIX}/share/zsh/site-functions:$FPATH"
  fi

  # Under Darwin, we also want iTerm2 integration if possible.
  if [ -f ${HOME}/.iterm2_shell_integration.zsh ]; then
    source "${HOME}/.iterm2_shell_integration.zsh"
  fi
fi

# Personal preferences
export EDITOR=vim
export GO111MODULE=on
if [ -f $HOME/.keysrc ]; then
  source $HOME/.keysrc
fi

# Rust
if [ -d $HOME/.cargo ]; then
  source $HOME/.cargo/env
fi

# Haskell
if [ -d $HOME/.ghcup ]; then
  export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
fi

# Fastlane
if [ -d $HOME/.fastlane ]; then
  export PATH="$HOME/.fastlane/bin:$PATH"
fi

# Haxe
if [ -d $BREW_PREFIX/lib/haxe ]; then
  export HAXE_STD_PATH="$BREW_PREFIX/lib/haxe/std"
fi

# RVM must be last.
if [ -d $HOME/.rvm ]; then
  PATH=${PATH}:$HOME/.rvm/bin
  source "$HOME/.rvm/scripts/rvm"
fi

autoload -Uz compinit
compinit

# Google Cloud tries to prematurely call compinit for completion.
# I don't want >1 second load times.
if [ -d ${HOME}/bin/google-cloud-sdk ]; then
  source ${HOME}/bin/google-cloud-sdk/path.zsh.inc
  source ${HOME}/bin/google-cloud-sdk/completion.zsh.inc
fi
