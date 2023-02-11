# My NixOS configuration
Beware: this config is still under construction (it takes a while to port all my old dotfiles over).

## Installation
TODO

## Important things
This repo will reside in your home directory, whilst being overlay-mounted to `/etc/nixos`.\
Therefore, the `.git` folder is excluded from system rebuilds, which makes developing easier.

Additionally, two important shell aliases are provided:
- `switch`: remounts /etc/nixos and runs `nixos-rebuild switch`
- `upgrade`: performs an upgrade of this configuration's flake.

## Screenshot
![A screenshot](./screenshot.png)
