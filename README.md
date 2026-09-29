<p align="center">
  <img src=".github/banner.svg" width="100%" alt="Reference Tools · 5G Broadcast - TV and Radio Services: 5G Broadcast Transmitter for QRD and CRD">
</p>

<p align="center">
  An extension of an MBMS-enabled eNodeB that operates as a 5G Broadcast transmitter for Qualcomm
  Reference Design (QRD) and CRD devices.
</p>

<p align="center">
  <img alt="Status: under development"
    src="https://img.shields.io/badge/Status-Under%20Development-e67e22">
  <a href="https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd/releases"><img alt="Version"
    src="https://img.shields.io/github/v/release/5G-MAG/rt-mbms-tx-for-qrd-and-crd?label=Version"></a>
  <a href="LICENSE"><img alt="License: GNU AGPL v3.0"
    src="https://img.shields.io/badge/License-AGPL%20v3.0-blue"></a>
</p>

<p align="center">
  <a href="https://www.5g-mag.com/reference-tools/5g-broadcast/">Project page</a> &nbsp;&middot;&nbsp;
  <a href="https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd/issues">Issues</a> &nbsp;&middot;&nbsp;
  <a href="https://www.5g-mag.com/contributing">Contributing</a>
</p>

---

## At a glance

|  |  |
|---|---|
| **Part of** | [5G Broadcast - TV and Radio Services](https://www.5g-mag.com/reference-tools/5g-broadcast/), alongside [rt-libflute](https://github.com/5G-MAG/rt-libflute), [rt-mbms-application](https://github.com/5G-MAG/rt-mbms-application), [rt-mbms-application-provider](https://github.com/5G-MAG/rt-mbms-application-provider), [rt-mbms-bmsc](https://github.com/5G-MAG/rt-mbms-bmsc), [rt-mbms-client](https://github.com/5G-MAG/rt-mbms-client), [rt-mbms-examples](https://github.com/5G-MAG/rt-mbms-examples), [rt-mbms-gw](https://github.com/5G-MAG/rt-mbms-gw), [rt-mbms-modem](https://github.com/5G-MAG/rt-mbms-modem), [rt-mbms-mw-android](https://github.com/5G-MAG/rt-mbms-mw-android) and [rt-mbms-tx](https://github.com/5G-MAG/rt-mbms-tx) |

## Introduction

The transmitter is based on the [srsRAN_4G Project](https://github.com/srsran/srsRAN_4G). Its
eNodeB has been modified to disable uplink connectivity for the reception of MBMS data. Background
on LTE-based 5G Broadcast is at <https://www.5g-mag.com/reference-tools/5g-broadcast/>.

## Install dependencies

On Ubuntu 22.04 LTS:

```
sudo apt update
sudo apt install ssh g++ git libboost-atomic-dev libboost-thread-dev libboost-system-dev libboost-date-time-dev libboost-regex-dev libboost-filesystem-dev libboost-random-dev libboost-chrono-dev libboost-serialization-dev libwebsocketpp-dev openssl libssl-dev ninja-build libspdlog-dev libmbedtls-dev libboost-all-dev libconfig++-dev libsctp-dev libfftw3-dev vim libcpprest-dev libusb-1.0-0-dev net-tools smcroute python3-pip clang-tidy gpsd gpsd-clients libgps-dev
sudo snap install cmake --classic
sudo pip3 install cpplint
sudo pip3 install psutil
```

## Downloading

```
git clone --recurse-submodules https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd.git
cd rt-mbms-tx-for-qrd-and-crd
git submodule update
mkdir build && cd build
```

## Building

```
cmake -DCMAKE_INSTALL_PREFIX=/usr -GNinja ..
ninja
```

## Installing

```
sudo ninja install
```

### Configuration after installation

Install the configuration files:

```
sudo ./srsran_install_configs.sh user
```

After installation, adjust the enb, rr and epc configuration files to your frequency, bandwidth,
TX gain, MNC, MCC and other settings.

[Configuration Templates](https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd/tree/main/Config-Template)
can be downloaded and placed in `/root/.config/srsran/` for use after installation.

Copy the adapted `sib.conf.mbsfn` file to the build directory:

```
cd rt-mbms-tx-for-qrd-and-crd/Config-Template
cp sib.conf.mbsfn ../build/sib.conf.mbsfn
```

## Running

Starting the transmitter takes three steps:

1. Start the MBMS gateway
2. Start the EPC
3. Start the eNodeB

Running the eNodeB may require an SDR platform; see the
[SDR platforms tutorial](https://www.5g-mag.com/reference-tools/3gpp-platforms/tutorials/sdr-platforms).

### Starting the MBMS gateway

```
sudo srsmbms
```

The MBMS gateway receives multicast packets on one tunnel interface, packs them into GTP-U packets
and sends them to the eNodeB over another tunnel interface. The command above creates the `sgi_mb`
interface (visible with `ifconfig`). For incoming data to be routed correctly, add this route:

```
sudo route add -net 239.11.4.0 netmask 255.255.255.0 dev sgi_mb
```

Any multicast route can be used.

### Starting the EPC

```
sudo srsepc
```

### Starting the eNodeB

```
cd rt-mbms-tx-for-qrd-and-crd/build
sudo srsenb/src/srsenb
```

## Contributing

Contributions are welcome. How to raise an issue, fork the repository and open a pull request, and
the Contributor License Agreement required before code can be merged, are described at
<https://www.5g-mag.com/contributing>.

## License

Distributed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE). The srsRAN
copyright and the notices for third-party files used within srsRAN are in [COPYRIGHT](COPYRIGHT).
