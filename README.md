# .dotfiles
These are my dotfiles for Arch Linux. They are mostly productivity-focused and value function over form, but I think that they look quite decent.
I have split many program configuration files into directories to enable modularity.
Also, every program (or group of related programs) has its own tag, so users of these dotfiles can choose which features they want.

## Installation
1. Clone this repo to the standard rcm dotfile location:  
   `git clone https://github.com/42LoCo42/.dotfiles ~/.dotfiles`
2. Install with `cd ~/.dotfiles && ./install.sh`

The installation will launch an interactive tag-selection menu. Select tags according to your needs and preferences.
Required packages will be automatically installed, with the exception of:
- the terminal: I use [xst-aur-patched](https://github.com/42LoCo42/xst-aur-patched), which is just the AUR package
  with the bold-is-not-bright patch applied (though I plan to include an install script for this)
- the icon font for polybar: it is the Pro version of Font Awesome, so you have to obtain from *some* source

## Screenshot
![dotfiles](https://user-images.githubusercontent.com/39183040/165969701-acde10e3-80b6-4d70-ad6f-1d6bb61357b9.png)
