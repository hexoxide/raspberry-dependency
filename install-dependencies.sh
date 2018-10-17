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

##############################
## end Function Definitions ##
##############################

# verify existence of requirements
echo "verifying requirements..."; 
for i in "${REQUIRE[@]}" 
  do if hash "$i" 2>/dev/null; then
    echo >&2 "Found ${i}";
  else
    echo >&2 "Could not find: ${i} , is not installed.";
    exit 1;
  fi
done

echo "Full path was determined to be: $ROOT"

# Determine if necessary symlink exists because boost is incorrectly detects python path on Manjaro
if [ -d /usr/include/python3.7m/ ] && [ ! -d /usr/include/python3.7/ ]; then
  echo "Symlinking python to prevent boost error when building"
  sudo ln -s /usr/include/python3.7m/ /usr/include/python3.7
fi

verifyNetwork

cd "$ROOT" || exit

# Update all the submodules their submodules
if [ ! "$TRAVIS" ]; then
  echo "Updating submodules."
  git submodule update --init --recursive
fi

# Compile and install cmake
cd "$ROOT/cmake" || exit
./bootstrap
make -j 4
sudo make install

# Compile and install boost
cd "$ROOT/boost" || exit
./bootstrap.sh --prefix=/usr/local
sudo ./b2 install

sudo cp libs/program_options/include/boost/program_options.hpp /usr/local/include/boost/
sudo cp libs/signals/include/boost/signals.hpp /usr/local/include/boost/
sudo cp libs/process/include/boost/process.hpp /usr/local/include/boost/
sudo cp libs/signals2/include/boost/signals2.hpp /usr/local/include/boost/
sudo cp libs/parameter/include/boost/parameter.hpp /usr/local/include/boost/
sudo cp libs/iterator/include/boost/function_output_iterator.hpp /usr/local/include/boost/
sudo cp -R libs/signals2/include/boost/signals2/ /usr/local/include/boost/
sudo cp -R libs/process/include/boost/process/ /usr/local/include/boost/
sudo cp -R libs/uuid/include/boost/uuid/ /usr/local/include/boost/
sudo cp -R libs/msm/include/boost/msm/ /usr/local/include/boost/
sudo cp -R libs/dll/include/boost/dll /usr/local/include/boost/
sudo cp -R libs/core/include/boost/utility/ /usr/local/include/boost/

# Compile and install yaml-cpp
cd "$ROOT/yaml-cpp" || exit
if [ -d "build" ]; then
  mkdir build
fi
cd build || exit
cmake ../
make -j 4
sudo make install

# Compile and install libzmq
cd "$ROOT/libzmq" || exit
if [ -d "build" ]; then
  mkdir build
fi
cd build || exit
cmake ../
make -j 4
sudo make install

# Compile and install FairLogger
cd "$ROOT/FairLogger" || exit
if [ -d "build" ]; then
  mkdir build
fi
cd build || exit
cmake ../
make -j 4
sudo make install

# Compile and install FairMQ
cd "$ROOT/FairMQ" || exit
if [ -d "build" ]; then
  mkdir build
fi
cd build || exit
cmake -DBUILD_TESTING=0 ../
make -j 1 # Device will run out of memory if more then 1 compile job runs in parallel!
sudo make install

# Compile and install ZooKeeper
cd "$ROOT/zookeeper" || exit
ant deb