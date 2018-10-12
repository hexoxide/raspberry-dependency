#!/bin/bash

#     Raspberry Dependencies installation and management for 02 software experiments.
#     Copyright (C) 2018 Amsterdam University of Applied Sciences.

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program. If not, see <https://www.gnu.org/licenses/>.

MY_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
INSTALL_DIR="qemu-rasp"
MNT_ROOT="root"
MNT_BOOT_RASP="bootr"
MNT_BOOT_CENT="bootc"

# List of commands required for execution of the setup script 
REQUIRE=("fdisk" "qemu-system-aarch64" "git" "wget")

# CentOS raspberry image
CENTOS_BASE_URL=http://mirror.centos.org/altarch/7/isos/armhfp/
CENTOS_XZ_IMAGE=CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-1804-sda.raw.xz
CENTOS_IMAGE=${CENTOS_XZ_IMAGE: : -3}

# Raspbian image
RASPBIAN_BASE_URL=https://downloads.raspberrypi.org/
RASPBIAN_ZIP_IMAGE=raspbian_lite_latest
RASPBIAN_IMAGE=`ls qemu-rasp/ | grep raspbian`

################################
## Start Function Definitions ##
################################

function pingGateway() {
  ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo ok || echo error
}

function verifyNetwork() {
  # Attempt to ping the gateway to verify an active network connection
  if [ $(pingGateway) == error ]; then
    echo "An active internet connection is required."
    read -p "Does this machine have an active internet connection: yes[y] / no[n]" yn
    case $yn in
      [Dd]* ) INET=true; break;;
      [Rr]* ) INET=false; break;;
      * ) echo "Please answer: yes[y] / no[n]";;
    esac
  else
    INET=true
  fi

  # Halt execution if not connected to the internet
  if [ ! INET ]; then
    echo "Can not continue without internet connection."
    exit 1;
  fi
}

##############################
## end Function Definitions ##
##############################

# verify existence of requirements
echo "verifying requirements..."; 
for i in "${REQUIRE[@]}" 
  do if hash $i 2>/dev/null; then
    echo >&2 "Found ${i}";
  else
    echo >&2 "Could not find: ${i} , is not installed.";
    exit 1;
  fi
done

# Create install directories if not exists
if [ ! -d "$MY_ROOT/$INSTALL_DIR/$MNT_BOOT_RASP" ]; then
  mkdir $INSTALL_DIR/$MNT_BOOT_RASP
fi
if [ ! -d "$MY_ROOT/$INSTALL_DIR/$MNT_BOOT_CENT" ]; then
  mkdir $INSTALL_DIR/$MNT_BOOT_CENT
fi

cd $INSTALL_DIR

# download and extract centos image
if [ ! -f "$MY_ROOT/$INSTALL_DIR/$CENTOS_IMAGE" ]; then
  verifyNetwork
  wget $CENTOS_BASE_URL$CENTOS_XZ_IMAGE
  unxz $CENTOS_XZ_IMAGE
fi

# download and extract raspbian image
if [ ! -f "$MY_ROOT/$INSTALL_DIR/$RASPBIAN_IMAGE" ]; then
  verifyNetwork
  wget $RASPBIAN_BASE_URL$RASPBIAN_ZIP_IMAGE
  unzip $RASPBIAN_ZIP_IMAGE
  rm $RASPBIAN_ZIP_IMAGE
fi

# retrieve image information
RAW_INFO=`fdisk -l $RASPBIAN_IMAGE`

# Determine size of sectors in image file
RAW_SECTOR_INFO=`echo $"$RAW_INFO" | grep -E "Sector size[^%]*bytes \/ " | cut -d '/' -f 3`
SECTOR_SIZE=${RAW_SECTOR_INFO: 1 : -6}
echo "Determined Raspbian image sector size to be: $SECTOR_SIZE bytes"

# Determine start point of
SECTOR_START=`echo $"$RAW_INFO" | grep "c W95" | cut -d ' ' -f 8`
echo "Determined Raspbian image root partition to start at sector $SECTOR_START"

# Compute the root partition offset
let "BOOT_OFFSET=$SECTOR_SIZE * $SECTOR_START"
echo "Determined Raspbian image boot partition offset to be: $BOOT_OFFSET"

sudo mount -v -o offset=$BOOT_OFFSET -t vfat $RASPBIAN_IMAGE bootr/

# retrieve image information
RAW_INFO=`fdisk -l $CENTOS_IMAGE`

# Determine size of sectors in image file
RAW_SECTOR_INFO=`echo $"$RAW_INFO" | grep -E "Sector size[^%]*bytes \/ " | cut -d '/' -f 3`
SECTOR_SIZE=${RAW_SECTOR_INFO: 1 : -6}
echo "Determined CentOS image sector size to be: $SECTOR_SIZE bytes"

# Determine start point of
SECTOR_START=`echo $"$RAW_INFO" | grep "c W95" | cut -d ' ' -f 9`
echo "Determined CentOS image root partition to start at sector $SECTOR_START"

# Compute the root partition offset
let "BOOT_OFFSET=$SECTOR_SIZE * $SECTOR_START"
echo "Determined CentOS image boot partition offset to be: $BOOT_OFFSET"

sudo mount -v -o offset=$BOOT_OFFSET -t vfat $CENTOS_IMAGE bootc/