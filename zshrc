#########
# zplug configuraton
#########
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh

zplug "felixr/docker-zsh-completion"

# Stuff that modifies
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:2

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

setopt prompt_subst # Make sure prompt is able to be generated properly.
setopt auto_cd # Get that ~ in here.
setopt hist_ignore_all_dups # Goodbye, random duplicates.
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

export PATH="${HOME}/bin:$PATH"

# Android SDK
if [ -d ${HOME}/bin/android-sdk ]; then
  export PATH="${HOME}/bin/android-sdk/platform-tools:${PATH}"
fi

# Google Cloud tools
if [ -d ${HOME}/bin/google-cloud-sdk ]; then
  source ${HOME}/bin/google-cloud-sdk/completion.zsh.inc
  source ${HOME}/bin/google-cloud-sdk/path.zsh.inc
fi

if [ -d ${HOME}/bin/YaTools ]; then
  export PATH="${HOME}/bin/YaTools:${PATH}"
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
  source /etc/profile.d/vte.sh
fi

if [[ $OSTYPE == darwin* ]]; then
  # Fix Homebrew pathing.
  export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
fi

if [ -s $HOME/.rvm/scripts/rvm ]; then
  source "$HOME/.rvm/scripts/rvm"
  export PATH="$PATH:$HOME/.rvm/bin"
fi

# Adapted from https://github.com/isaacmorneau/dotfiles/blob/882f11172a2c0fd1aa7020d627d2978e5d60f6b0/.bashrc#L125-L130
function mvsane () {
  for F in "$@"
  do
    mv "$F" $(echo "$F" | sed -r 's/[ ]+/_/g;s/[^a-zA-Z0-9_.-]//g;s/[_-]{2,}/-/g;')
  done
}

# Personal preferences
export EDITOR=vim
export GO111MODULE=on
if [ -f $HOME/.keysrc ]; then
  source $HOME/.keysrc
fi

if [ -d $HOME/.ghcup ]; then
  export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
fi
