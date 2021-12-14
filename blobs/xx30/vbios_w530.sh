#!/bin/bash

BLOBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROM_PARSER_SHA256SUM="082a04e789d2343a01649327a7c9ba5ae5186a2b38e3d9de15c078845e732819  master.zip"
UEFI_EXTRACT_SHA256SUM="c9cf4066327bdf6976b0bd71f03c9e049ae39ed19ea3b3592bae3da8615d26d7  UEFIExtract_NE_A58_linux_x86_64.zip"
VBIOS_FINDER_SHA256SUM="bbffe3c9c8a64c31485618fae2a2892fe2f4da7b45adaaba136fd45056bce9cd  master.zip"
BIOS_UPDATE_SHA256SUM="4769fdcfe34c40d285b8c7290305f04eb91d692f4bf25acd291d114353a958c2  g5uj39us.exe"
K2000M_ROM_SHA256SUM="5005b582019b16d2073cec8cd384ec908d8ff38ab286a6dd65eadc0e89bfb4a8  vbios_10de_0ffb_1.rom"
K1000M_ROM_SHA256SUM="6e28abb61cd4c69be7bd64e487681164cb487a48d77276f3108e3f192ceeee16  vbios_10de_0ffc_1.rom"
IGPU_ROM_SHA256SUM="10b292c19322e7bb7db53350d2775d37b72a784292ea5686cd0f92af929f4916  vbios_8086_0106_1.rom"

echo "### Creating temp dir"
extractdir=$(mktemp -d)
cd "$extractdir"

echo "### Installing basic dependencies"
sudo apt update
sudo apt install -y wget ruby ruby-dev ruby-bundler p7zip-full upx-ucl 

echo "### Downloading rom-parser dependency"
wget https://github.com/awilliam/rom-parser/archive/refs/heads/master.zip

echo "### Verifying expected hash of rom-parser"
echo "$ROM_PARSER_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing rom-parser dependency"
unzip master.zip
rm master.zip
cd rom-parser-master
make
sudo cp rom-parser /usr/sbin/
cd ..
rm -r rom-parser-master

echo "### Downloading UEFIExtract dependency"
wget https://github.com/LongSoft/UEFITool/releases/download/A58/UEFIExtract_NE_A58_linux_x86_64.zip

echo "### Verifying expected hash of UEFIExtract"
echo "$UEFI_EXTRACT_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing UEFIExtract"
unzip UEFIExtract_NE_A58_linux_x86_64.zip
sudo mv UEFIExtract /usr/sbin/
rm UEFIExtract_NE_A58_linux_x86_64.zip

echo "### Downloading VBiosFinder"
wget https://github.com/coderobe/VBiosFinder/archive/refs/heads/master.zip

echo "### Verifying expected hash of VBiosFinder"
echo "$VBIOS_FINDER_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing VBiosFinder"
unzip master.zip
rm master.zip
cd VBiosFinder-master
bundle install --path=vendor/bundle

echo "### Downloading latest Lenovo bios update for w530"
wget https://download.lenovo.com/pccbbs/mobiles/g5uj39us.exe

echo "### Verifying expected hash of bios update"
echo "$BIOS_UPDATE_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Finding, extracting and saving vbios"
mv g5uj39us.exe /home/$USER/
./vbiosfinder extract /home/$USER/g5uj39us.exe
rm /home/$USER/g5uj39us.exe

echo "Verifying expected has of extracted roms"
cd output
echo "$K2000M_ROM_SHA256SUM" | sha256sum --check || { echo "K2000M rom failed sha256sum verification..." && exit 1; }
echo "$K1000M_ROM_SHA256SUM" | sha256sum --check || { echo "K1000M rom failed sha256sum verification..." && exit 1; }
echo "$IGPU_ROM_SHA256SUM" | sha256sum --check || { echo "iGPU rom Failed sha256sum verification..." && exit 1; }

echo "### Cleaning Up"
mv vbios_10de_0ffb_1.rom $BLOBDIR/10de,0ffb.rom
mv vbios_10de_0ffc_1.rom $BLOBDIR/10de,0ffc.rom
mv vbios_8086_0106_1.rom $BLOBDIR/8086,0106.rom
cd ..
cd ..
rm -r VBiosFinder-master
cd ..
rm -r "$extractdir"
