![](https://travis-ci.com/hexoxide/raspberry-dependency.svg?branch=master)

# raspberry-dependency
Automatic dependency installation and management for the raspberry pi 3 B+. This project will setup the necessary tools to run experiments related to the CERN O2-balancer. O2-balancer experiments are used to determine feasible network load-balancing algorithms which will be required after the upgrade to ALICE. ALICE will be upgraded during LS2 which is due to finish Februari 2021.

The following tools will be installed by using this tool.
  
| Library/Tool                                            	| Version required 		| Version specified	|
|-----------------------------------------------------------|-----------------------|-------------------|
| [FairMQ](https://github.com/FairRootGroup/FairMQ)       	| 1.1.5      			| 1.1.5				|
| [ZeroMQ](https://github.com/zeromq/libzmq)              	| 4.2.2*     			| 4.2.1				|
| [Zookeeper](https://zookeeper.apache.org/)              	| 3.4.9      			| 3.4.9				|
| [Cmake](https://github.com/Kitware/CMake)               	| 3.11.0     			| 3.11.0			|
| [Boost](https://www.boost.org/)                         	| 1.66.0     			| 1.66.0			|
| [Yaml-cpp](https://github.com/jbeder/yaml-cpp)          	| 0.5.2      			| 0.5.2				|
| [FairLogger](https://github.com/FairRootGroup/FairLogger)	| 1.0.6					| _NONE_			|
| [Compiler](https://gcc.gnu.org/)                        	| gcc 8.2.0*  			| gcc 6.3.0 		|

_*Version differs from specification as defined in Mitch Puls his paper._

## Index

1. [Requirements](#1-requirements)
2. [Emulating raspberry-pi hardware](#3-emulating-raspberry-pi-hardware)
3. [References](#4-references)
4. [Glossary](#5-glossary)

## 1. Requirements
A raspberry-pi model 3 B+ is required with the appropriate operating system image installed on the inserted MicroSD card. A MicroSD card of at least 16GB in size is highly recommended. Alternatively the raspberry-pi can be emulated using QEMU, please see [2. Emulating raspberry-pi hardware](#3-emulating-raspberry-pi-hardware).

* Raspberry-pi 3 B+ (alternatively see 2.)
* 16GB MicroSD card
* Manjaro ARM 17

### 1.1 Reasons for choosing Manjaro as Linux distribution

An environment as similar as possible to the one used at CERN is desired, however, it has proven to be unfeasible to use CentOS. This is due to the limitations the Raspberry pi version has in comparison to the CentOS x86_64 image. One of the main reasons is the inability to switch of gcc version, normally, a tool called `scl` provides the switching for specific versions of many development tools. The version of gcc supplied with CentOS is incompatible with the version of boost that is specified in many of the previous experiments. Furthermore the version of gcc is not capable of compiling c++2011 features which is required by CERN. To continue to use CentOS gcc would have been required to be build from source.

## 2. Setup 

After setting up a fresh image of manjaro-17 a few commands need to be executed to install necessary dependencies.

```
sudo -s
pacman -Syu
pacman-mirrors -g
pacman -Sy archlinux-keyring manjaro-keyring
pacman-key --refresh-key
pacman -S gcc git wget htop make icu base-devel python jdk8-openjdk ant cppunit
exit
```

Afterwards execute the `install-dependencies.sh` script to perform the entire setup operation. The entire process can take up to 4 hours to complete. Execute the code below to set a unique hostname for the node(Change the HOSTNAME value).

```
HOSTNAME="manjaro-arm-1"
su root
echo "$HOSTNAME" > /etc/hostname
echo -e "CERN loadbalancing pi \nHostname: $HOSTNAME" > /etc/motd
```

## 3. Emulating raspberry-pi hardware

`qemu-system-aarch64 -M raspi3 -m 1024 -kernel kernel8.img -dtb bcm2837-rpi-3-b.dtb -serial stdio -drive file=qemu-rasp/2018-06-27-raspbian-stretch-lite.img,format=raw,if=sd -append "console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait"`

## 4. References

1. [Emulate raspberry-pi with QEMU](https://azeria-labs.com/emulate-raspberry-pi-with-qemu/)
2. [CentOS AltArch Raspberry pi 3 documentation](https://wiki.centos.org/SpecialInterestGroup/AltArch/Arm32/RaspberryPi3)
3. [Compiling the Linux kernel for raspberry pi 3](https://devsidestory.com/build-a-64-bit-kernel-for-your-raspberry-pi-3/)

## 5. Glossary

[Online glossary](https://github.com/hexoxide/documentation/blob/master/glossary.md)
