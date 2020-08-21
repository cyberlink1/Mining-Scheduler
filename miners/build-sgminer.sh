#!/bin/bash
clear
echo "************************************************"
echo "|  Building a copy of sgminer for this system  |"
echo "************************************************"
echo ""
echo "Installing Build Environment"
apt-get -y install git g++ yasm autoconf automake libtool pkgconf gnutls-dev  uthash-dev
echo "Downloading AMD SDK"
git clone https://github.com/GPUOpen-Tools/common_lib_amd_adl.git
echo "Downloading sgminer"
git clone https://github.com/genesismining/sgminer-gm.git
cd sgminer-gm
echo "Downloading init and updates"
git submodule init
git submodule update
echo "Running Autoreconf"
autoreconf -fi
echo "Copying ADL SDK include files for GPU support"
cd ADL_SDK/
cp ../../common_lib_amd_adl/include/* .
cd ..
echo "Configuring sgminer build"
CFLAGS="-Os -Wall -march=native -I/opt/AMDAPPSDK-3.0/include" LDFLAGS="-L/opt/amdgpu-pro/lib/x86_64-linux-gnu" ./configure --disable-git-version --prefix=/opt/sgminer-5.5.5
echo "Building SGMiner"
make -j3
make install
echo "Removing build directories"
cd ..
rm -r ./sgminer-gm
rm -r ./common_lib_amd_adl
