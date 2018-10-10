#!/bin/bash 
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# List of commands required for execution of the setup script 
REQUIRE=("git" "wget" "gcc" "g++")

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

cd $ROOT

# Update all the submodules their submodules
git submodule update --init --recursive

# Compile and install cmake
cd cmake
./bootstrap