#########
# zplug configuraton
#########
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh

zplug "felixr/docker-zsh-completion"

# Stuff that modifies
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "johnhamelink/rvm-zsh", lazy:true
zplug 'mfaerevaag/wd', as:command, use:"wd.sh", hook-load:"wd() { . $ZPLUG_REPOS/mfaerevaag/wd/wd.sh }"

bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

source $HOME/.zsh/expand-multiple-dots.zsh # cd .../.../<tab>?
setopt prompt_subst # Make sure prompt is able to be generated properly.
setopt auto_cd # Get that ~ in here.
setopt hist_ignore_all_dups # Goodbye, random duplicates.
setopt hist_ignore_space # ' ' more like ._.
setopt inc_append_history # Write it asap
setopt share_history # goodbye, out-of-sync cross-shell passwords
setopt auto_list # magic and things involving listing of items
setopt auto_menu # Use a menu because I'm _that_ type of person

zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3

# Configure prompt to my liking.
BULLETTRAIN_PROMPT_ORDER=(
  time
  status
  custom
  dir
  screen
  ruby
  go
  git
)
BULLETTRAIN_PROMPT_CHAR=">"
BULLETTRAIN_DIR_BG="black"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# Let's do this.
zplug load

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
  source ${HOME}/bin/google-cloud-sdk/completion.zsh.inc
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
fi

# Personal preferences
export EDITOR=vim
export GO111MODULE=on
if [ -f $HOME/.keysrc ]; then
  source $HOME/.keysrc
fi

if [ -d $HOME/.cargo ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -d $HOME/.ghcup ]; then
  export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
fi

if [ -d $HOME/.fastlane ]; then
  export PATH="$HOME/.fastlane/bin:$PATH"
fi
