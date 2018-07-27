#########
# zplug configuraton
#########
export ZPLUG_HOME=$HOME/.zplug
source $ZPLUG_HOME/init.zsh

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/iterm2", from:oh-my-zsh
zplug "felixr/docker-zsh-completion"
zplug "lib/*", from:oh-my-zsh

# Stuff that modifies
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:3
zplug "zsh-users/zsh-completions", defer:2

setopt prompt_subst # Make sure prompt is able to be generated properly.
setopt auto_cd # Get that ~ in here.
zplug "caiogondim/bullet-train.zsh", use:bullet-train.zsh-theme, defer:3

# Configure prompt to my liking.
BULLETTRAIN_PROMPT_ORDER=(
  time
  status
  custom
  context
  dir
  screen
  ruby
  go
  git
)
BULLETTRAIN_PROMPT_CHAR=">"

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

# Local stuff, homebrew python, theos
export PATH="${HOME}/bin:${HOME}/bin/android-sdk/platform-tools:${PATH}"

# Google Cloud tools
source ${HOME}/bin/google-cloud-sdk/completion.zsh.inc
source ${HOME}/bin/google-cloud-sdk/path.zsh.inc

export EDITOR=nano

# Go
export GOPATH=${HOME}/go
export PATH=${GOPATH}/bin:${PATH}

# theos
export THEOS=${HOME}/.theos
export PATH=${THEOS}/bin:$PATH
export THEOS_DEVICE_IP=localhost THEOS_DEVICE_PORT=2222

# devkitPro and the like
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export DEVKITPPC=/opt/devkitpro/devkitPPC
export PATH=/opt/devkitpro/tools/bin:$PATH

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

if [[ $OSTYPE == darwin* ]]; then
  # Fix Homebrew pathing.
  export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" ]]
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
