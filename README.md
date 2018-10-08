# raspberry-dependency
Automatic dependency installation and management for the raspberry pi 3 B+. This project will setup the necessary tools to run experiments related to the CERN O2-balancer. O2-balancer experiments are used to determine feasible network load-balancing algorithms which will be required after the upgrade to ALICE. ALICE will be upgraded during LS2 which is due to finish Februari 2021.

The following tools will be installed by using this tool.
  
| Library/Tool | Version    |
|--------------|------------|
| FairMQ       | 1.1.5      |
| ZeroMQ       | 4.2.1      |
| Zookeeper    | 3.4.9      |
| Cmake        | 3.11.0     |
| Boost        | 1.66.0     |
| Yaml-cpp     | 0.5.2      |
| Compiler     | gcc 6.3.0  |

## Index

1. [Requirements]()
2. [Emulating raspberry-pi hardware]()
3. [References]()
4. [Glossary]()

## 1. Requirements
A raspberry-pi model 3 B+ is required with the appropriate operating system image installed on the inserted MicroSD card. A MicroSD card of at least 16GB in size is highly recommended. Alternatively the raspberry-pi can be emulated using QEMU, please see [2. Emulating raspberry-pi hardware]().


* Raspberry-pi 3 B+ (alteratively see 2.)
* 16GB MicroSD card
* CentOS 7.0 i386 raspberry-pi image

## 2. Emulating raspberry-pi hardware

`qemu-system-aarch64 -M raspi3 -m 1024 -kernel kernel8.img -dtb bcm2837-rpi-3-b.dtb -serial stdio -drive file=qemu-rasp/2018-06-27-raspbian-stretch-lite.img,format=raw,if=sd -append "console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait"`

## 3. References

1. [Emulate raspberry-pi with QEMU](https://azeria-labs.com/emulate-raspberry-pi-with-qemu/)
2. [CentOS AltArch Raspberry pi 3 documentation](https://wiki.centos.org/SpecialInterestGroup/AltArch/Arm32/RaspberryPi3)
3. [Compiling the Linux kernel for raspberry pi 3](https://devsidestory.com/build-a-64-bit-kernel-for-your-raspberry-pi-3/)

## 4. Glossary

@TODO: Create global gloassary as single point of reference for entirety of documentation instead of having to copy a table around everywhere and anywhere.

| Name  | Abbreviation  | Meaning |
|-------|---------------|---------|
| CERN  |               |         |
| ALICE |               |         |
| LS2   |               |         |
| QEMU  |               |         |
