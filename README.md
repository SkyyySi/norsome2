# QRLinux AwesomeWM configuration

## General

This repository contains the configuration files ([aka dotfiles / dots / .files](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory))
for the [awesome window manager](https://awesomewm.org/) used by QRLinux (which, as of the time of me writing this, doesn't really... exist yet).

### Installation

To install, you have to...

 - have a system running [Arch Linux](https://archlinux.org/) (or a compatible [distro](https://en.wikipedia.org/wiki/Linux_distribution), for example [EndeavourOS](https://endeavouros.com/))
 - have the following packages installed:
   - from the [official repositories](https://archlinux.org/packages/): `alacritty code firefox lxqt pasystray pavucontrol playerctl unclutter xscreensaver`
   - from the [Arch user repository (AUR)](https://aur.archlinux.org/packages/): `awesome-git picom-ibhagwan-git`
 - run these commands:
```sh
[ -d "$HOME/.config/awesome" ] && mv "$HOME/.config/awesome" "$HOME/.config/.awesome_$(date '+%m_%d_%Y')"
git clone https://github.com/skyyySi/norsome2.git "$HOME/.config/awesome"
```
 - log out and log back into awesome

### Recommendations

If you want a more fully-featured experience, I recommend that you...
 - Install `ulauncher` from the [AUR](https://aur.archlinux.org/packages/) as well as `nm-applet` and `blueman-applet`
 from the [official repositories](https://archlinux.org/packages/).
