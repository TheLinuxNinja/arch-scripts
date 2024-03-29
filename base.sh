#!/bin/bash
################################################################################
### Installing Base Arch Linux By:                                           ###
### Erik Sundquist                                                           ###
################################################################################
### Review and edit before using                                             ###
################################################################################
set -e
################################################################################
### Set Your System Locale Here                                              ###
################################################################################
function LOCALE() {
  ALOCALE="en_US.UTF-8"
}
################################################################################
### Set Your Country                                                         ###
################################################################################
function COUNTRY() {
  CNTRY="US"
}
################################################################################
### Set Your Keyboard Map Here                                               ###
################################################################################
function KEYMAP() {
  AKEYMAP="us"
}
################################################################################
### Set Your Hostname (Name Of Your Computer) Here                           ###
################################################################################
function HOSTNAME() {
  clear
  HOSTNM=$(dialog --stdout --inputbox "Enter hostname" 10 20) || exit 1
  : ${HOSTNM:?"hostname cannot be empty"}
}
################################################################################
### Select Hard Drive To Partition/Format Here                               ###
################################################################################
function DRVSELECT() {
  clear
  DEVICELIST=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
  HD=$(dialog --stdout --menu "Select root disk" 0 0 0 ${DEVICELIST}) || exit 1
}
################################################################################
### Set Your Command Line Font (Shell) Here                                  ###
################################################################################
function CLIFONT() {
  clear
  pacstrap /mnt terminus-font
  DEFFNT="ter-120n"
}
################################################################################
### Set Your Timezone Here                                                   ###
################################################################################
function STIMEZONE() {
  TIMEZNE='America/Los_Angeles'
}
################################################################################
### Set Username And Password Here                                           ###
################################################################################
function UNAMEPASS() {
  clear
  USRNM=$(dialog --stdout --inputbox "Enter username" 0 0) || exit 1
  clear
  : ${USRNM:?"user cannot be empty"}
  # User password
  UPASSWD=$(dialog --stdout --passwordbox "Enter user password" 0 0) || exit 1
  clear
  : ${UPASSWD:?"password cannot be empty"}
  UPASSWD2=$(dialog --stdout --passwordbox "Enter user password again" 0 0) || exit 1
  clear
  [[ "$UPASSWD" == "$UPASSWD2" ]] || ( echo "Passwords did not match"; exit 1; )
}
################################################################################
### Set Admin (Root) Password Here                                           ###
################################################################################
function ROOTPASSWORD() {
  clear
  RPASSWD=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
  clear
  : ${RPASSWD:?"password cannot be empty"}
  RPASSWD2=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
  clear
  [[ "$RPASSWD" == "$RPASSWD2" ]] || ( echo "Passwords did not match"; exit 1; )
}
################################################################################
### Partition And Format The Hard Drive Here                                 ###
################################################################################
function PARTHD() {
  clear
  echo "##############################################################################"
  echo "### Partitioning the Hard Drive                                            ###"
  echo "##############################################################################"
  sleep 3
  sgdisk -Z ${HD}
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    parted ${HD} mklabel gpt mkpart primary fat32 1MiB 301MiB set 1 esp on mkpart primary ext4 301MiB 100%
    mkfs.fat -F32 ${HD}1
  else
    #BIOS Partition
    parted ${HD} mklabel msdos mkpart primary ext4 2MiB 100% set 1 boot on
  fi
}
################################################################################
### Format The Hard Drive With EXT4 Filesystem Here                          ###
################################################################################
function FMTEXT4() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as EXT4                                      ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.ext4 ${HD}2
  else
    #BIOS Partition
    mkfs.ext4 ${HD}1
  fi
}
################################################################################
### Format The Hard Drive With BTRFS Filesystem Here                         ###
################################################################################
function FMTBTRFS() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as BTRFS                                     ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.btrfs -f ${HD}2
  else
    #BIOS Partition
    mkfs.btrfs ${HD}1
  fi
}
################################################################################
### Format The Hard Drive With XFS Filesystem Here                           ###
################################################################################
function FMTXFS() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as XFS                                       ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.xfs -f ${HD}2
  else
    #BIOS Partition
    mkfs.xfs -f ${HD}1
  fi
}
################################################################################
### Format The Hard Drive With ReiserFS Filesystem Here                       ###
################################################################################
function FMTREISERFS() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as ReiserFS                                  ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.reiserfs -f ${HD}2
  else
    #BIOS Partition
    mkfs.reiserfs -f ${HD}1
  fi
}
################################################################################
### Format The Hard Drive With JFS Filesystem Here                       ###
################################################################################
function FMTJFS() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as JFS                                       ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.jfs -f ${HD}2
  else
    #BIOS Partition
    mkfs.jfs -f ${HD}1
  fi
}
################################################################################
### Format The Hard Drive With NILFS2 Filesystem Here                       ###
################################################################################
function FMTNILFS2() {
  clear
  echo "##############################################################################"
  echo "### Formatting the Hard Drive as NILFS2                                    ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mkfs.fat -F32 ${HD}1
    mkfs.nilfs2 -f ${HD}2
  else
    #BIOS Partition
    mkfs.nilfs2 -f ${HD}1
  fi
}
################################################################################
### Mount The Hard Drive Here                                                ###
################################################################################
function MNTHD() {
  if [[ -d /sys/firmware/efi/efivars ]]; then
    #UEFI Partition
    mount ${HD}2 /mnt
    mkdir /mnt/boot
    mount ${HD}1 /mnt/boot
  else
    mount ${HD}1 /mnt
  fi
}
################################################################################
### Install the Base Packages Here                                           ###
################################################################################
function BASEPKG() {
  clear
  echo "##############################################################################"
  echo "### Installing the Base Packages                                           ###"
  echo "##############################################################################"
  sleep 3
  pacstrap /mnt base base-devel linux linux-firmware linux-headers nano networkmanager man-db man-pages git btrfs-progs systemd-swap xfsprogs reiserfsprogs jfsutils nilfs-utils
  genfstab -U /mnt >> /mnt/etc/fstab
}
################################################################################
### Systemd Boot Setting Here                                                ###
################################################################################
function SYSDBOOT() {
  clear
  echo "##############################################################################"
  echo "### Creating Boot Information                                              ###"
  echo "##############################################################################"
  sleep 3
  arch-chroot /mnt mkdir -p /boot/loader/entries
  arch-chroot /mnt bootctl --path=/boot install
  # Loader Configuring
  rm /mnt/boot/loader/loader.conf
  echo "default arch" >> /mnt/boot/loader/loader.conf
  echo "timeout 3" >> /mnt/boot/loader/loader.conf
  echo "console-mode max" >> /mnt/boot/loader/loader.conf
  echo "editor no" >> /mnt/boot/loader/loader.conf
  # Arch Linux - Standard Kernel
  echo "title Arch Linux" >> /mnt/boot/loader/entries/arch.conf
  echo "linux /vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
  echo "#initrd  /intel-ucode.img" >> /mnt/boot/loader/entries/arch.conf
  echo "#initrd /amd-ucode.img" >> /mnt/boot/loader/entries/arch.conf
  echo "initrd  /initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
  echo "options root=PARTUUID="$(blkid -s PARTUUID -o value "$HD"2)" nowatchdog rw" >> /mnt/boot/loader/entries/arch.conf
  # Arch Linux - Fallback Kernel
  echo "title Arch Linux-Fallback" >> /mnt/boot/loader/entries/arch-fallback.conf
  echo "linux /vmlinuz-linux" >> /mnt/boot/loader/entries/arch-fallback.conf
  echo "#initrd  /intel-ucode.img" >> /mnt/boot/loader/entries/arch-fallback.conf
  echo "#initrd /amd-ucode.img" >> /mnt/boot/loader/entries/arch-fallback.conf
  echo "initrd  /initramfs-linux-fallback.img" >> /mnt/boot/loader/entries/arch-fallback.conf
  echo "options root=PARTUUID="$(blkid -s PARTUUID -o value "$HD"2)" nowatchdog rw" >> /mnt/boot/loader/entries/arch-fallback.conf
}
################################################################################
### Grub Boot Settings Here                                                  ###
################################################################################
function GRUBBOOT() {
  clear
  echo "##############################################################################"
  echo "### Installing and Configuring GRUB Boot Loader                            ###"
  echo "##############################################################################"
  sleep 3
  if [[ -d /sys/firmware/efi/efivars ]]; then
    pacstrap /mnt grub efibootmgr
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable
    arch-chroot /mnt pacman -S --needed --noconfirm grub-customizer
  else
    pacstrap /mnt grub
    arch-chroot /mnt grub-install --target=i386-pc ${HD}
    arch-chroot /mnt pacman -S --needed --noconfirm grub-customizer
  fi
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}
################################################################################
### Setting up Systemd Swap Here                                             ###
################################################################################
function SYSDSWAP() {
  clear
  echo "##############################################################################"
  echo "### Setting up SystemD Swap                                                ###"
  echo "##############################################################################"
  sleep 3
  rm /mnt/etc/systemd/swap.conf
  echo "#zswap_enabled=1" >> /mnt/etc/systemd/swap.conf
  echo "#zswap_compressor=zstd" >> /mnt/etc/systemd/swap.conf     # lzo lz4 zstd lzo-rle lz4hc
  echo "#zswap_max_pool_percent=25" >> /mnt/etc/systemd/swap.conf # 1-99
  echo "#zswap_zpool=z3fold" >> /mnt/etc/systemd/swap.conf        # zbud z3fold (note z3fold requires kernel 4.8+)
  echo "#zram_enabled=1" >> /mnt/etc/systemd/swap.conf
  echo "#zram_size=\$(( RAM_SIZE / 4 ))" >> /mnt/etc/systemd/swap.conf    # This is 1/4 of ram size by default.
  echo "#zram_count=\${NCPU}" >> /mnt/etc/systemd/swap.conf               # Device count
  echo "#zram_streams=\${NCPU}" >> /mnt/etc/systemd/swap.conf             # Compress streams
  echo "#zram_alg=zstd" >> /mnt/etc/systemd/swap.conf                    # See $zswap_compressor
  echo "#zram_prio=32767" >> /mnt/etc/systemd/swap.conf                  # 1 - 32767
  echo "swapfc_enabled=1" >> /mnt/etc/systemd/swap.conf
  echo "swapfc_force_use_loop=0" >> /mnt/etc/systemd/swap.conf          # Force usage of swapfile + loop
  echo "swapfc_frequency=1" >> /mnt/etc/systemd/swap.conf               # How often to check free swap space in seconds
  echo "swapfc_chunk_size=256M" >> /mnt/etc/systemd/swap.conf           # Size of swap chunk
  echo "swapfc_max_count=32" >> /mnt/etc/systemd/swap.conf              # Note: 32 is a kernel maximum
  echo "swapfc_min_count=1" >> /mnt/etc/systemd/swap.conf               # Minimum amount of chunks to preallocate
  echo "swapfc_free_ram_perc=35" >> /mnt/etc/systemd/swap.conf          # Add first chunk if free ram < 35%
  echo "swapfc_free_swap_perc=15" >> /mnt/etc/systemd/swap.conf         # Add new chunk if free swap < 15%
  echo "swapfc_remove_free_swap_perc=55" >> /mnt/etc/systemd/swap.conf  # Remove chunk if free swap > 55% && chunk count > 2
  echo "swapfc_priority=50" >> /mnt/etc/systemd/swap.conf               # Priority of swapfiles (decreasing by one for each swapfile).
  echo "swapfc_path=/var/lib/systemd-swap/swapfc/" >> /mnt/etc/systemd/swap.conf
# Only for swapfile + loop
  echo "swapfc_nocow=1" >> /mnt/etc/systemd/swap.conf              # Disable CoW on swapfile
  echo "swapfc_directio=1" >> /mnt/etc/systemd/swap.conf           # Use directio for loop dev
  echo "swapfc_force_preallocated=1" >> /mnt/etc/systemd/swap.conf # Will preallocate created files
  echo "swapd_auto_swapon=1" >> /mnt/etc/systemd/swap.conf
  echo "swapd_prio=1024" >> /mnt/etc/systemd/swap.conf
  arch-chroot /mnt systemctl enable systemd-swap
}
################################################################################
### Set Number Of CPUs In MAKEFLAGS Here                                     ###
################################################################################
function MAKEFLAGS_CPU() {
  clear
  echo "##############################################################################"
  echo "### Fixing the Makeflags for the Compiler                                  ###"
  echo "##############################################################################"
  sleep 3
  numberofcores=$(grep -c ^processor /proc/cpuinfo)
  case $numberofcores in

      16)
          echo "You have " $numberofcores" cores."
          echo "Changing the makeflags for "$numberofcores" cores."
          sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j16"/g' /mnt/etc/makepkg.conf
          echo "Changing the compression settings for "$numberofcores" cores."
          sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 16 -z -)/g' /mnt/etc/makepkg.conf
          ;;
      8)
          echo "You have " $numberofcores" cores."
          echo "Changing the makeflags for "$numberofcores" cores."
          sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j8"/g' /mnt/etc/makepkg.conf
          echo "Changing the compression settings for "$numberofcores" cores."
          sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 8 -z -)/g' /mnt/etc/makepkg.conf
          ;;
      6)
          echo "You have " $numberofcores" cores."
          echo "Changing the makeflags for "$numberofcores" cores."
          sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j8"/g' /mnt/etc/makepkg.conf
          echo "Changing the compression settings for "$numberofcores" cores."
          sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 6 -z -)/g' /mnt/etc/makepkg.conf
          ;;
      4)
          echo "You have " $numberofcores" cores."
          echo "Changing the makeflags for "$numberofcores" cores."
          sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/g' /mnt/etc/makepkg.conf
          echo "Changing the compression settings for "$numberofcores" cores."
          sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 4 -z -)/g' /mnt/etc/makepkg.conf
          ;;
      2)
          echo "You have " $numberofcores" cores."
          echo "Changing the makeflags for "$numberofcores" cores."
          sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j2"/g' /mnt/etc/makepkg.conf
          echo "Changing the compression settings for "$numberofcores" cores."
          sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 2 -z -)/g' /mnt/etc/makepkg.conf
          ;;
      *)
          echo "We do not know how many cores you have."
          echo "Do it manually."
          ;;

  esac
}
################################################################################
### Needed Packages To Install                                               ###
################################################################################
function NEEDEDPKGS() {
  clear
  echo "##############################################################################"
  echo "### Installing Needed Packages                                             ###"
  echo "##############################################################################"
  sleep 3
  pacstrap /mnt neofetch
  pacstrap /mnt git
  pacstrap /mnt wget
  pacstrap /mnt rsync
  pacstrap /mnt htop
  pacstrap /mnt openssh
  pacstrap /mnt archlinux-wallpaper
  pacstrap /mnt glances
  pacstrap /mnt bashtop
  pacstrap /mnt bpytop
  pacstrap /mnt packagekit
  pacstrap /mnt reflector
  pacstrap /mnt bat
  pacstrap /mnt mc
  pacstrap /mnt lynx
  pacstrap /mnt ncdu
  pacstrap /mnt bwm-ng
  pacstrap /mnt lsd
  pacstrap /mnt gtop
}
################################################################################
### Ask what format for the HD                                               ###
################################################################################
function WHATFMT() {
  clear
  echo "##############################################################################"
  echo "### What is your preferred drive format                                    ###"
  echo "### 1)  EXT4 - Standard Linux Format                                       ###"
  echo "### 2)  BTRFS                                                              ###"
  echo "### 3)  XFS                                                                ###"
  echo "### 4)  ReiserFS                                                           ###"
  echo "### 5)  JFS                                                                ###"
  echo "### 6)  NILFS2                                                             ###"
  echo "##############################################################################"
  read case;
  case $case in
    1)
    FMTEXT4
    ;;
    2)
    FMTBTRFS
    ;;
    3)
    FMTXFS
    ;;
    4)
    FMTREISERFS
    ;;
    5)
    FMTJFS
    ;;
    6)
    FMTNILFS2
    ;;
  esac
}
################################################################################
### Ask which bootloader                                                     ###
################################################################################
function BOOTTYPE() {
  clear
  echo "##############################################################################"
  echo "### What is your preferred boot loader                                     ###"
  echo "### 1)  systemd                                                            ###"
  echo "### 2)  GRUB (Must select this if using non-EFI system)                    ###"
  echo "##############################################################################"
  read case;
  case $case in
    1)
    SYSDBOOT
    ;;
    2)
    GRUBBOOT
    ;;
  esac
}
################################################################################
### Needed utilities to install system                                       ###
################################################################################
function NEEDED_INSTALL() {
  clear
  echo "##############################################################################"
  echo "### Installing needed software                                             ###"
  echo "##############################################################################"
  sleep 3
  pacman -S --noconfirm --needed dialog
}
################################################################################
### Misc Settings                                                            ###
################################################################################
function MISC_SETTINGS() {
  clear
  echo "##############################################################################"
  echo "### Misc Settings Being Installed                                          ###"
  echo "##############################################################################"
  sleep 3
  arch-chroot /mnt systemctl enable NetworkManager
  ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
  arch-chroot /mnt systemctl enable systemd-resolved
  sed -i "s/^#\(${ALOCALE}\)/\1/" /mnt/etc/locale.gen
  arch-chroot /mnt locale-gen
  echo "LANG=${ALOCALE}" >> /mnt/etc/locale.conf
  echo "${HOSTNM}" >> /mnt/etc/hostname
  sed -i 's/^#\ \(%wheel\ ALL=(ALL)\ NOPASSWD:\ ALL\)/\1/' /mnt/etc/sudoers
  echo "KEYMAP="${AKEYMAP} >> /mnt/etc/vconsole.conf
  #sed -i "$ a FONT=${DEFFNT}" /mnt/etc/vconsole.conf
  echo "FONT="${DEFFNT} >> /mnt/etc/vconsole.conf
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/${TIMEZNE} /etc/localtime
  sed -i 's/'#Color'/'Color'/g' /mnt/etc/pacman.conf
  #sed -i 's/\#Include/Include'/g /mnt/etc/pacman.conf
  sed -i '/^#\[multilib\]/{
    N
    s/^#\(\[multilib\]\n\)#\(Include\ .\+\)/\1\2/
  }' /mnt/etc/pacman.conf
  sed -i 's/\#\[multilib\]/\[multilib\]'/g /mnt/etc/pacman.conf
  arch-chroot /mnt pacman -Sy
  echo "set linenumbers" >> /mnt/etc/nanorc
  echo 'include "/usr/share/nano/*.nanorc"' >> /mnt/etc/nanorc
}
################################################################################
### BashRC Configuration                                                     ###
################################################################################
function BASHRC_CONF() {
  clear
  echo "##############################################################################"
  echo "### Configuring the BashRC file                                            ###"
  echo "##############################################################################"
  sleep 3
  echo " " >> /mnt/etc/bash.bashrc
  echo "# Check to see if neofetch is installed and if so display it" >> /mnt/etc/bash.bashrc
  echo "if [ -f /usr/bin/neofetch ]; then clear & neofetch; fi" >> /mnt/etc/bash.bashrc
  sed -i 's/alias/#alias'/g /mnt/etc/skel/.bashrc
  echo "# Setting up some aliases" >> /mnt/etc/skel/.bashrc
  echo "alias ls='lsd'" >> /mnt/etc/skel/.bashrc
  echo "alias cat='bat'" >> /mnt/etc/skel/.bashrc
  echo "alias fd='ncdu'" >> /mnt/etc/skel/.bashrc
  echo "alias netsp='bwm-ng'" >> /mnt/etc/skel/.bashrc
  echo "alias df='duf'" >> /mnt/etc/skel/.bashrc
  echo "alias font='fontpreview-ueberzug'" >> /mnt/etc/skel/.bashrc
  echo "alias sysmon='gtop'" >> /mnt/etc/skel/.bashrc
  echo "alias conf-theme='~/.config/gtk-3.0/settings.ini'" >> /mnt/etc/skel/.bashrc
  echo "alias video='ytfzf -t --upload-time=today '" >> /mnt/etc/skel/.bashrc
  echo "alias videos='ytfzf -tS '" >> /mnt/etc/skel/.bashrc
  echo "alias cpu='cpufetch'" >> /mnt/etc/skel/.bashrc
}
################################################################################
### Fix the Pacman Keyring                                                   ###
################################################################################
function PACMAN_KEYS() {
  clear
  echo "################################################################################"
  echo "### Fixing The Pacman (Repo) Keys                                            ###"
  echo "################################################################################"
  sleep 2
  sudo pacman-key --init
  sudo pacman-key --populate archlinux
  sudo reflector --country US --latest 20 --sort rate --verbose --save /etc/pacman.d/mirrorlist
  sudo pacman -Sy
}
################################################################################
### Main Program - Edit At Own Risk                                          ###
################################################################################
clear
timedatectl set-ntp true
NEEDED_INSTALL
COUNTRY
LOCALE
KEYMAP
STIMEZONE
HOSTNAME
DRVSELECT
UNAMEPASS
ROOTPASSWORD
PARTHD
WHATFMT
MNTHD
PACMAN_KEYS
BASEPKG
CLIFONT
SYSDSWAP
MAKEFLAGS_CPU
NEEDEDPKGS
MISC_SETTINGS
BASHRC_CONF
BOOTTYPE
################################################################################
### Setting Passwords and Creating the User                                  ###
################################################################################
clear
echo "##############################################################################"
echo "### Setting Up Users and Final Settings                                    ###"
echo "##############################################################################"
sleep 3
arch-chroot /mnt useradd -m -g users -G storage,wheel,power,kvm -s /bin/bash "${USRNM}"
echo "$UPASSWD
$UPASSWD
" | arch-chroot /mnt passwd $USRNM

echo "$RPASSWD
$RPASSWD" | arch-chroot /mnt passwd
wget http://raw.githubusercontent.com/lotw69/arch-scripts/master/complete.sh
chmod +x complete.sh
cp complete.sh /mnt/home/$USRNM/
clear
echo "##############################################################################"
echo "### Installation Is Complete, Please Reboot And Have Fun                   ###"
echo "### To Setup The DE and Other Needed Packages Please Type                  ###"
echo "### 'sudo pacman -Syyu' after the 1st boot and log on as user, then reboot ###"
echo "### Then type './complete.sh' to complete rest of the system install.      ###"
echo "##############################################################################"
