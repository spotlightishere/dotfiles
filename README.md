# Spotlight's dotfiles
I heavily utilize macOS, BSD and various Linux distributions, so it's important that these dotfiles work consistently across them all.

As such, I utilize [Nix](https://nixos.org) with [home-manager](https://github.com/nix-community/home-manager).


## Expectations
Please don't consider this a great basis for your own configuration - it works well for me!
As such, some things may make assumptions you would not as well :)

A few assumptions are made, reflecting my current knowledge of Nix:
 - All Darwin machines are assumed to be desktop devices.
    - (This is not true, but... we'll take it.)
 - All Linux machines are... not, and fit a dotfiles-only configuration.
    - (This is not true, but for the most part works due to packages being provided by other package managers.)

## Installation
This may require things to be adapted based on the platform.

```
git clone https://git.joscomputing.space/spotlight/dotfiles ~/.config/home-manager
# Or as otherwise described for flake usage within the Home Manager manual:
# https://nix-community.github.io/home-manager/index.html#sec-flakes-standalone
nix run home-manager/master -- init --switch
```
