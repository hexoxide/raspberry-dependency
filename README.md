# raspberry-dependency
Automatic dependency installation and management for the raspberry pi 3 B+. This project will setup the necessary tools to run experiments related to the CERN O2-balancer. O2-balancer experiments are used to determine feasible network load-balancing algorithms which will be required after the upgrade to ALICE. ALICE will be upgraded during LS2 which is due to finish Februari 2021.

The following tools will be installed by using this tool.
  
| Library/Tool                                            | Version    |
|---------------------------------------------------------|------------|
| [FairMQ](https://github.com/FairRootGroup/FairMQ)       | 1.1.5      |
| [ZeroMQ](https://github.com/zeromq/libzmq)              | 4.2.1      |
| [Zookeeper](https://zookeeper.apache.org/)              | 3.4.9      |
| [Cmake](https://github.com/Kitware/CMake)               | 3.11.0     |
| [Boost](https://www.boost.org/)                         | 1.66.0     |
| [Yaml-cpp](https://github.com/jbeder/yaml-cpp)          | 0.5.2      |
| [Compiler](https://gcc.gnu.org/)                        | gcc 6.3.0  |

## Index

1. [Requirements](#1-requirements)
2. [Emulating raspberry-pi hardware](#2-emulating-raspberry-pi-hardware)
3. [References](#3-references)
4. [Glossary](#4-glossary)

## 1. Requirements
A raspberry-pi model 3 B+ is required with the appropriate operating system image installed on the inserted MicroSD card. A MicroSD card of at least 16GB in size is highly recommended. Alternatively the raspberry-pi can be emulated using QEMU, please see [2. Emulating raspberry-pi hardware](#2-emulating-raspberry-pi-hardware).


* Raspberry-pi 3 B+ (alteratively see 2.)
* 16GB MicroSD card
* CentOS 7.0 i386 raspberry-pi image

## 2. Emulating raspberry-pi hardware

## 3. References

1. [Emulate raspberry-pi with QEMU](https://azeria-labs.com/emulate-raspberry-pi-with-qemu/)
2. [CentOS AltArch Raspberry pi 3 documentation](https://wiki.centos.org/SpecialInterestGroup/AltArch/Arm32/RaspberryPi3)

## 4. Glossary

@TODO: Create global gloassary as single point of reference for entirety of documentation instead of having to copy a table around everywhere and anywhere.

| Name  | Abbreviation  | Meaning |
|-------|---------------|---------|
| CERN  |               |         |
| ALICE |               |         |
| LS2   |               |         |
| QEMU  |               |         |
