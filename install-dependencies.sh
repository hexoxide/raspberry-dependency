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

# Determine absolute path of this file regardless of path from which the file is executed
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# List of commands required for execution of the setup script 
REQUIRE=("git" "wget" "gcc" "g++" "make" "python" "icuinfo" "ping" "grep" "cut" "hash" "dirname" "pwd" "ln" "cp" "doxygen")

BOOST_VERSION="1_66"

DEBUG=true
CMAKE_PARAMATERS=""

if $($DEBUG); then
  CMAKE_PARAMATERS="-DCMAKE_BUILD_TYPE=Debug"
fi

################################
## Start Function Definitions ##
################################

function pingGateway() {
  ping -q -w 1 -c 1 "$(ip r | grep default | cut -d ' ' -f 3)" > /dev/null && echo ok || echo error
}

function verifyNetwork() {
  # Attempt to ping the gateway to verify an active network connection
  if [ "$(pingGateway)" == error ]; then
    echo "An active internet connection is required."
    read -r -p "Does this machine have an active internet connection: yes[y] / no[n]" yn
    case $yn in
      [Yy]* ) INET=true;;
      [Nn]* ) ;;
      * ) echo "Please answer: yes[y] / no[n]";;
    esac
  else
    INET=true
  fi

  # Halt execution if not connected to the internet
  if [ ! $INET ]; then
    echo "Can not continue without internet connection."
    exit 1;
  fi
}

function verifyRequirement() {
  if hash "$1" 2>/dev/null; then
    echo >&2 "Found $1";
    return 0
  else
    echo >&2 "Could not find: $1 , is not installed.";
    return 1
  fi
}

##############################
## end Function Definitions ##
##############################

# verify existence of requirements
echo "verifying requirements..."; 
for i in "${REQUIRE[@]}" 
  do verifyRequirement "$i" || exit 1
done

echo "Full path was determined to be: $ROOT"

# Determine if necessary symlink exists because boost is incorrectly detects python path on Manjaro
if [ -d /usr/include/python3.7m/ ] && [ ! -d /usr/include/python3.7/ ]; then
  echo "Symlinking python to prevent boost error when building"
  sudo ln -s /usr/include/python3.7m/ /usr/include/python3.7
fi

# Set locale if not properly set
if ! grep -q "en_US" /etc/locale.gen; then
  echo "en_US.UTF-8 UTF-8" | sudo tee /etc/locale.gen
  sudo locale-gen
fi

if [ ! "$TRAVIS" ]; then
  verifyNetwork
fi

cd "$ROOT" || exit

# Copy cppunit.m4 into aclocal folder if it does not already exist
# this file is required by zookeeper.
if [ ! -f "/usr/share/aclocal/cppunit.m4" ]; then
  echo "Copying cppunit.m4"
  sudo cp cppunit.m4 /usr/share/aclocal/
fi

# Update all the submodules their submodules
if [ ! "$TRAVIS" ]; then
  echo "Updating submodules."
  git submodule update --init --recursive
fi

# Compile and install cmake
if ! verifyRequirement "cmake"; then
  cd "$ROOT/cmake" || exit
  ./bootstrap
  make -j 2
  sudo make install
fi

# Compile and install boost
if [ ! -f "/usr/local/include/boost/version.hpp" ] || ! grep -q $BOOST_VERSION /usr/local/include/boost/version.hpp; then
  cd "$ROOT/boost" || exit
  ./bootstrap.sh
  ./b2 
  sudo ./b2 install
  sudo cp libs/program_options/include/boost/program_options.hpp /usr/local/include/boost/
  sudo cp libs/signals/include/boost/signals.hpp /usr/local/include/boost/
  sudo cp libs/process/include/boost/process.hpp /usr/local/include/boost/
  sudo cp libs/signals2/include/boost/signals2.hpp /usr/local/include/boost/
  sudo cp libs/parameter/include/boost/parameter.hpp /usr/local/include/boost/
  sudo cp libs/iterator/include/boost/function_output_iterator.hpp /usr/local/include/boost/
  sudo cp libs/filesystem/include/boost/filesystem.hpp /usr/local/include/boost/
  sudo cp libs/format/include/boost/format.hpp /usr/local/include/boost/
  sudo cp -R libs/signals2/include/boost/signals2/ /usr/local/include/boost/
  sudo cp -R libs/process/include/boost/process/ /usr/local/include/boost/
  sudo cp -R libs/uuid/include/boost/uuid/ /usr/local/include/boost/
  sudo cp -R libs/msm/include/boost/msm/ /usr/local/include/boost/
  sudo cp -R libs/dll/include/boost/dll /usr/local/include/boost/
  sudo cp -R libs/core/include/boost/utility/ /usr/local/include/boost/
fi

# Compile and install yaml-cpp
if [ ! -f "/usr/local/lib/libyaml-cpp.so" ]; then
  cd "$ROOT/yaml-cpp" || exit
  if [ ! -d "build" ]; then
    mkdir build
  fi
  cd build || exit
  cmake -DBUILD_SHARED_LIBS=ON ../
  make -j 2
  sudo make install
fi

# Compile and install libzmq
if [ ! -f "/usr/local/lib/libzmq.so" ]; then
  cd "$ROOT/libzmq" || exit
  if [ ! -d "build" ]; then
    mkdir build
  fi
  cd build || exit
  cmake $CMAKE_PARAMATERS ../
  make -j 2
  sudo make install
fi

# Compile and install FairLogger
if [ ! -f "/usr/local/lib/libFairLogger.so" ]; then
  cd "$ROOT/FairLogger" || exit
  if [ ! -d "build" ]; then
    mkdir build
  fi
  cd build || exit
  cmake $CMAKE_PARAMATERS ../
  make -j 2
  sudo make install
fi

# Compile and install FairMQ
if [ ! -f "/usr/local/lib/libFairMQ.so" ]; then
  cd "$ROOT/FairMQ" || exit
  if [ ! -d "build" ]; then
    mkdir build
  fi
  cd build || exit
  cmake $CMAKE_PARAMATERS -DBUILD_TESTING=0 ../ # Do not build unit tests as it requires GTest as dependency
  make -j 1 # Device will run out of memory if more then 1 compile job runs in parallel!
  sudo make install
fi

cd "$ROOT" || exit

# Compile and install ZooKeeper
#cd "$ROOT/zookeeper-arch" || exit
#makepkg -Acs
#PACKAGE="$(echo ./*.pkg.tar.xz)"
#sudo pacman -U "$PACKAGE"

# Compile and install ZooKeeper c bindings
# cd "$ROOT/zookeeper/src/c" || exit
# export CFLAGS="-Wno-error" # Don't worry about it~ just a bug in GCC 8.2
# libtoolize --force
# aclocal
# autoheader
# automake --force-missing --add-missing
# autoconf
# ./configure
# make -j 2
# make install
