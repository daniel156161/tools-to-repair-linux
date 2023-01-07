#!/bin/bash

if [ -z "$1" ]; then
  echo "Bitte geben sie ihre luks partition an"
  exit 1
fi
if [ -z "$2" ]; then
  echo "Bitte geben den Name für ihre Root BTRFS SubVolumen an"
  exit 1
fi
if [ -z "$3" ]; then
  echo "Bitte geben sie ihre EFI partition an"
  exit 1
fi

# Stelle sicher, dass das System als root ausgeführt wird
if [ "$(id -u)" != "0" ]; then
  echo "Dieses Skript muss als root ausgeführt werden" 1>&2
  exit 1
fi

# Stelle sicher, dass das manjaro-system-tool installiert ist
pacman -S manjaro-system-tools --noconfirm

# Öffne die verschlüsselte LUKS-Partition
cryptsetup luksOpen "$1" luks

# Mounte das BTRFS-Dateisystem
mount -t btrfs -o subvol="$2" /dev/mapper/luks /mnt

# Mounte die EFI-Partition
mount "$3" /mnt/boot/efi

# Wechsle in das gemountete Dateisystem
manjaro-chroot /mnt

# Installiere den GRUB-Bootloader neu
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

# Beende die manjaro-chroot-Umgebung
exit

# Schließe die LUKS-Partition
cryptsetup luksClose luks

# Entferne das gemountete Dateisystem
umount /mnt/boot/efi
umount /mnt

echo "GRUB wurde erfolgreich neu installiert."
