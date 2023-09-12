# 5G Broadcast Transmitter for QRD and CRD

This repository holds an implementation of an LTE-based 5G Broadcast transmitter tailored to operate with Qualcomm Reference Design (QRD) and QRC devices.

## Introduction

[]

### Specifications

A list of specification related to this repository is available in the [Standards Wiki](https://github.com/5G-MAG/Standards/wiki/MBMS-&-LTE-based-5G-Broadcast:-Relevant-Specifications).

### About the implementation

[]

## Install dependencies

On Ubuntu 22.04 LTS:
````
sudo apt update
sudo apt install ssh g++ git libboost-atomic-dev libboost-thread-dev libboost-system-dev libboost-date-time-dev libboost-regex-dev libboost-filesystem-dev libboost-random-dev libboost-chrono-dev libboost-serialization-dev libwebsocketpp-dev openssl libssl-dev ninja-build libspdlog-dev libmbedtls-dev libboost-all-dev libconfig++-dev libsctp-dev libfftw3-dev vim libcpprest-dev libusb-1.0-0-dev net-tools smcroute python3-pip clang-tidy gpsd gpsd-clients libgps-dev
sudo snap install cmake --classic
sudo pip3 install cpplint
sudo pip3 install psutil
````

## Install SDR drivers

````
sudo apt install libsoapysdr-dev soapysdr-tools
````

### Using BladeRF with Soapy
For BladeRF the relevant package is named *soapysdr-module-bladerf*. Install it by running:
````
sudo apt install soapysdr-module-bladerf
````
Finally, install the BladeRF firmware:
````
sudo bladeRF-install-firmware
````

### Check SDR availability
Check if the SDR can be found on your system
````
SoapySDRUtil --find
````

The output should look like this:
````
######################################################
##     Soapy SDR -- the SDR abstraction library     ##
######################################################
Found device 2
  backend = libusb
  device = 0x02:0x09
  driver = bladerf
  instance = 0
  label = BladeRF #0 [ANY]
  serial = ANY
````

## Downloading
````
git clone --recurse-submodules -b qrd-tx https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd.git

cd rt-mbms-tx-for-qrd-and-crd

git submodule update

mkdir build && cd build
````

## Building
``
cmake -DCMAKE_INSTALL_PREFIX=/usr -GNinja ..
``
``
ninja
``

## Installing
``
sudo ninja install
``

## Configuration after installation
Install the configuration:
``
sudo ./srsran_install_configs.sh user
``

After the installtion, you have to adjust the enb, rr, epc config files to your desired frequency, bandwith, tx gain, MNC, MCC ...

or you can use our [templates](https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd/tree/qrd-tx/Config-Template). Download them and place them in ``/root/.config/srsran/``.
You can still change the frequency, gain or whatever if you want to. 

Also make sure to copy the adapted sib.conf.mbsfn file to the build directory:
````
cd rt-mbms-tx-for-qrd-and-crd/
cp sib.conf.mbsfn build/sib.conf.mbsfn
````

## Running
Starting the transmitter requires the follwing 3 steps:
1. Starting the MBMS-Gateway
2. Starting the EPC
3. Starting the ENB

### Starting the MBMS-Gateway
``
sudo srsmbms
``

The MBMS-GW receives multicast packets on one tunnel interface, packages them to GTP-U-Packets and sends them to ENB over another tunnel interface.
The command above creates the sgi_mb interface (you could see it by entering ``ifconfig`` for example). In order for the incoming data to be routed correctly, a route has to be added:

``
sudo route add -net 239.11.4.0 netmask 255.255.255.0 dev sgi_mb
``

You can use any multicast route. 

### Starting the EPC
``
sudo srsepc
``

### Starting the ENB
````
cd rt-mbms-tx-for-qrd-and-crd/build

sudo srsenb/src/srsenb
````

After this, the transmitter is running and is ready to receive a multicast stream. Now you can, for example, transcode a local .mp4 file to rtp with ffmpeg:

``
ffmpeg -stream_loop -1 -re -i <Input-file> -vcodec copy -an -f rtp_mpegts udp://239.11.4.50:9988
``
