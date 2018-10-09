#! /bin/bash

#Boot from live USB

# Config Install
## setup 
  `timedatectl set-ntp true`

## Create and format partitions
### Check hdd partitions with 
  `fdisk l`
### create partitions with for GPT partition. remember to set UEFI boot from bios config
  `gdisk /dev/sda`
### create `/efi` partition. 
  `/dev/sda1`
### create `swap` partition. 
  `/dev/sda2`
### create `/root` partition.
  `/dev/sda3`
### create `/home` partition.
  `/dev/sda4`
### format /root,/home swap and efi partitions
  `mkfs.ext4 /dev/sda3`
  `mkfs.ext4 /dev/sda4`
  `mkswap /dev/sda2`
  `swapon /dev/sda2`
  `mkfs.fat -F32 /dev/sda1`
### mount partitions
  `mkdir /mnt/home`
  `mkdir /mnt/efi`
  `mnt /dev/sda3 /mnt`
  `mnt /dev/sda4 /mnt/home`
  `mnt /dev/sda1 /mnt/efi`


## Install arch linux
### Get fastest mirrors
  `cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup`
  `curl -s "https://www.archlinux.org/mirrorlist/?protocol=https&use_mirror_status=on" | sed -e `s/^#Server/Server/` -e `/#/d` | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist`
### Install and configure GRUb
  `pacman -Sy grub efibootmanager`
  `grub-install --target=x86_64-efi --efi-directory=/mnt/efi --bootloader-id=GRUB`
  `grub-mkconfig -o /boot/grub/grub.cfg`
### Install OS
  `pacstrap /mnt base base-devel`
### Generate fstab
  `genfstab -U /mnt >> /mnt/etc/fstab`
### chroot 
  `arch-chroot /mnt`
### set timezone
  `ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime`
### set hardware clock to generate /etc/adjtime. This command assumes the hardware clock is set to UTC
  `hwclock --systohc`
### Uncomment en_US ISO-8859-1 UTF-8 and other needed locales in /etc/locale.gen, and generate them with
  `locale-gen`
### Set  in `etc/locale.conf` file
  `LANG=en_US.iso88591`
### Set hostname and hosts
  `#/etc/hostname`
  `hostname`
  `#/etc/hosts`
  `127.0.0.1 localhost`
  `::1		localhost`
  `127.0.1.1 myhostname.localdomain myhostname`
### set root password
  `passwd`
### create system user
  `useradd --create-home username`
  `usermod -aG wheel username`
  `passwd username` # set password
### add user to 
  `visudo` # comment out wheel group config 
### Exit, unmount partitions and reboot
  `exit`
  `umount -R /mnt`
  `reboot`

## login and configure admin user 
### install required softwares
  `sudo gvim pacman -Sy i3-wm dmenu i3status conky xorg xorg-xinit xorg-server openssh ttf-ms-fonts alsa-utils htop git docker zsh pcmanfm firefox flashplugin pepper-flash vlc dropbox keepassx2`
  `yaourt -Sy nvm consolas-font ttf-ms-fonts google-chrome opera-developer`
### configure i3
  `exec i3` # in ~/.xinitrc
### generate ssh
  `ssh-keygen -t ed25519`
### configure git
  `git config --global user.email "imonir.com@gmail.com"`
  `git config --global user.name "Moniruzzaman Monir"`
### dns config in `/etc/resolv.conf`
  `nameserver 8.8.8.8`
  `nameserver 8.8.4.4`

### add ssh key to github.com
### clone utils repo 
  `git clone git@github.com:dostokhan/utils.git ~/Work/dostokhan/utils`
### symlink config files
  `cd ~/Work/dostokhan/utils/dotfiles/`
  `sh ./link-config.sh`

### reboot and login to window manager
### Install spf13 vim config
  `sh <(curl https://j.mp/spf13-vim3 -L)`
### Install oh-my-zsh
  `sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`




