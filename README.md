# Spotlight's dotfiles
On devices I consider personal, I like having a similar style within zsh. I heavily utilize macOS, BSD and various Linux, so it's important that these dotfiles work consistently across them all.

I make heavy usage of Git submodules. Occasionally, these are updated. Please ensure when pulling my dotfiles that you also `git submodule update`.

## Installation
```
git clone --recursive https://git.joscomputing.space/spotlight/dotfiles ~/.dotfiles
cp ~/.dotfiles/dotfilesrc ~/.dotfilesrc
pip3 install dotfiles
dotfiles --sync --force
```

This creates a symbolic link from any file or directory within `~/.dotfiles/` to their respective place in `~/`. I prefer the `.dotfilesrc` to be managed as well.
