function load_plugin() {
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

# Theme requires oh-my-zsh's git functions.
source ~/.zsh/theme.zsh
source ~/.zsh/bullet-train.zsh/bullet-train.zsh-theme

# Configure prompt to my liking.
BULLETTRAIN_PROMPT_ORDER=(
  time
  status
  custom
  dir
  ruby
  go
  git
)
BULLETTRAIN_PROMPT_CHAR=">"
BULLETTRAIN_DIR_BG="black"

#########
# the env _essentials_
#########

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=3000
export SAVEHIST=$HISTSIZE
export PATH="${HOME}/bin:$PATH"
export GPG_TTY=$(tty)

# Android SDK
if [ -d ${HOME}/bin/android-sdk ]; then
  export PATH="${HOME}/bin/android-sdk/platform-tools:${PATH}"
fi

# Google Cloud tools
if [ -d ${HOME}/bin/google-cloud-sdk ]; then
  source ${HOME}/bin/google-cloud-sdk/path.zsh.inc
fi

# iTerm2 integration, only if detected as installed
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Go
export GOPATH=${HOME}/go
export PATH=${GOPATH}/bin:${PATH}

# theos
export THEOS=${HOME}/.theos
export PATH=${THEOS}/bin:$PATH

# devkitPro and the like
if [ -d /opt/devkitpro ]; then
  export DEVKITPRO=/opt/devkitpro
  export DEVKITARM=/opt/devkitpro/devkitARM
  export DEVKITPPC=/opt/devkitpro/devkitPPC
  export PATH=/opt/devkitpro/tools/bin:$PATH
fi

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  if [ -s /etc/profile.d/vte.sh ]; then
    source /etc/profile.d/vte.sh
  elif [ -s /etc/profile.d/vte-2.91.sh ]; then
    source /etc/profile.d/vte-2.91.sh
  fi
fi

if [[ $OSTYPE == darwin* ]]; then
  # Fix Homebrew pathing.
  export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
  # Fix ZSH site-functions pathing due to Homebrew.
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Personal preferences
export EDITOR=vim
export GO111MODULE=on
if [ -f $HOME/.keysrc ]; then
  source $HOME/.keysrc
fi

if [ -d $HOME/.cargo ]; then
  source $HOME/.cargo/env
fi

if [ -d $HOME/.ghcup ]; then
  export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
fi

if [ -d $HOME/.fastlane ]; then
  export PATH="$HOME/.fastlane/bin:$PATH"
fi

# RVM must be last.
if [ -d $HOME/.rvm ]; then
  PATH=${PATH}:$HOME/.rvm/bin
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" ]]
fi

autoload -Uz compinit
compinit

# Google Cloud tries to prematurely call compinit for completion.
# I don't want >1 second load times.
if [ -d ${HOME}/bin/google-cloud-sdk ]; then
  source ${HOME}/bin/google-cloud-sdk/completion.zsh.inc
fi
