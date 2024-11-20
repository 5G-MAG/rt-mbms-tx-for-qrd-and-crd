# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Avoid any questions
ARG DEBIAN_FRONTEND=noninteractive

# Update apt-get
RUN apt update

# Install dependencies
RUN apt install -y \
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

# Clone the repository
RUN git clone --recurse-submodules https://github.com/5G-MAG/rt-mbms-tx-for-qrd-and-crd.git /rt-mbms-tx-for-qrd-and-crd

# Set working directory
WORKDIR /rt-mbms-tx-for-qrd-and-crd

# Update submodules
RUN git submodule update

# Create build directory
RUN mkdir build

# Set working directory to build
WORKDIR /rt-mbms-tx-for-qrd-and-crd/build

# Run cmake
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -GNinja ..

# Run ninja
RUN ninja

# Install the project
RUN ninja install

# Install configuration
RUN ./srsran_install_configs.sh user

# Copy the docker-config directory into the container
COPY docker-config /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config

# Make sure the destination directory exists
RUN mkdir -p /root/.config/srsran

# Copy the default configurations
RUN cp -r /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config/bladerf /root/.config/srsran/

# Copy the adapted sib.conf.mbsfn file to the build directory
RUN cp ../sib.conf.mbsfn sib.conf.mbsfn

# Set execute permissions for the run.sh script
RUN chmod +x /etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config/run.sh

# Set entrypoint to execute the script
CMD ["/etc/5gmag/rt-mbms-tx-for-qrd-and-crd/docker-config/run.sh"]