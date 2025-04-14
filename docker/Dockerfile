# Use multi-architecture base image
FROM ubuntu:22.04

# Avoid any questions
ARG DEBIAN_FRONTEND=noninteractive

# Update apt-get
RUN apt-get update

# Install dependencies
RUN apt-get install -y \
    ssh g++ git libboost-atomic-dev libboost-thread-dev libboost-system-dev \
    libboost-date-time-dev libboost-regex-dev libboost-filesystem-dev \
    libboost-random-dev libboost-chrono-dev libboost-serialization-dev \
    libwebsocketpp-dev openssl libssl-dev ninja-build libspdlog-dev \
    libmbedtls-dev libboost-all-dev libconfig++-dev libsctp-dev libfftw3-dev \
    vim libcpprest-dev libusb-1.0-0-dev net-tools smcroute python3-pip \
    clang-tidy gpsd gpsd-clients libgps-dev libsoapysdr-dev soapysdr-tools \
    soapysdr-module-bladerf software-properties-common cmake

# Install Python packages
RUN pip3 install cpplint psutil

# Install BladeRF drivers
RUN apt install soapysdr-module-bladerf && \
    add-apt-repository ppa:nuandllc/bladerf && \
    apt update && \
    apt install -y bladerf

# Copy the entire directory into the image
COPY . /source/rt-mbms-tx-for-qrd-and-crd

# Set working directory
WORKDIR /source/rt-mbms-tx-for-qrd-and-crd

# Update submodules
RUN git submodule update

# Create build directory
RUN mkdir build

# Set working directory
WORKDIR /source/rt-mbms-tx-for-qrd-and-crd/build

# Run cmake
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -GNinja ..

# Run ninja
RUN ninja

# Install the project
RUN ninja install

# Install configuration
RUN ./srsran_install_configs.sh user

# Copy the docker-config directory into the container
COPY docker/config /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config

# Make sure the destination directory exists
RUN mkdir -p /root/.config/srsran

# Copy the default configurations
RUN cp -r /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config/bladerf /root/.config/srsran/

# Copy the adapted sib.conf.mbsfn file to the build directory
RUN cp /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config/sib.conf.mbsfn sib.conf.mbsfn

# Set entrypoint to execute the script
CMD ["/etc/run-docker.sh"]