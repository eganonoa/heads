#!/bin/bash

BLOBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROM_PARSER_SHA256SUM="f3db9e9b32c82fea00b839120e4f1c30b40902856ddc61a84bd3743996bed894  94a615302f89b94e70446270197e0f5138d678f3.zip"
UEFI_EXTRACT_SHA256SUM="c9cf4066327bdf6976b0bd71f03c9e049ae39ed19ea3b3592bae3da8615d26d7  UEFIExtract_NE_A58_linux_x86_64.zip"
VBIOS_FINDER_SHA256SUM="bd07f47fb53a844a69c609ff268249ffe7bf086519f3d20474087224a23d70c5  c2d764975115de466fdb4963d7773b5bc8468a06.zip"
BIOS_UPDATE_SHA256SUM="0aa078024a71d2772081c91994549153af6e4009b676425f877d562206516cae  8buj25us.exe"
W520_2000M_ROM_SHA256SUM="0076191ef7f3a4d4bb03445c1c9295f4895bc05df4521cea4be72a3aef761099  vbios_10de_0dda_1.rom"
W520_1000M_ROM_SHA256SUM="dce3a2f5ea1c3404939ff717623cc170f8ad34baa3cb586fbd3d7fcc5e68f6bd  vbios_10de_0dfa_1.rom"
IGPU_ROM_SHA256SUM="04221fc3d1178215b607a2944aa9eab79c2c435e18347cd59c46400c90e6cc59  vbios_8086_0106_1.rom"

echo "### Creating temp dir"
extractdir=$(mktemp -d)
cd "$extractdir"

echo "### Installing basic dependencies"
sudo apt update
sudo apt install -y wget ruby ruby-dev ruby-bundler p7zip-full upx-ucl 

echo "### Downloading rom-parser dependency"
wget https://github.com/awilliam/rom-parser/archive/94a615302f89b94e70446270197e0f5138d678f3.zip

echo "### Verifying expected hash of rom-parser"
echo "$ROM_PARSER_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing rom-parser dependency"
unzip 94a615302f89b94e70446270197e0f5138d678f3.zip
rm 94a615302f89b94e70446270197e0f5138d678f3.zip
cd rom-parser-94a615302f89b94e70446270197e0f5138d678f3
make
sudo cp rom-parser /usr/sbin/
cd ..
rm -r rom-parser-94a615302f89b94e70446270197e0f5138d678f3

echo "### Downloading UEFIExtract dependency"
wget https://github.com/LongSoft/UEFITool/releases/download/A58/UEFIExtract_NE_A58_linux_x86_64.zip

echo "### Verifying expected hash of UEFIExtract"
echo "$UEFI_EXTRACT_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing UEFIExtract"
unzip UEFIExtract_NE_A58_linux_x86_64.zip
sudo mv UEFIExtract /usr/sbin/
rm UEFIExtract_NE_A58_linux_x86_64.zip

echo "### Downloading VBiosFinder"
wget https://github.com/coderobe/VBiosFinder/archive/c2d764975115de466fdb4963d7773b5bc8468a06.zip

echo "### Verifying expected hash of VBiosFinder"
echo "$VBIOS_FINDER_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Installing VBiosFinder"
unzip c2d764975115de466fdb4963d7773b5bc8468a06.zip
rm c2d764975115de466fdb4963d7773b5bc8468a06.zip
cd VBiosFinder-c2d764975115de466fdb4963d7773b5bc8468a06
bundle install --path=vendor/bundle

echo "### Downloading latest Lenovo bios update for w530"
wget https://download.lenovo.com/pccbbs/mobiles/8buj25us.exe

echo "### Verifying expected hash of bios update"
echo "$BIOS_UPDATE_SHA256SUM" | sha256sum --check || { echo "Failed sha256sum verification..." && exit 1; }

echo "### Finding, extracting and saving vbios"
mv 8buj25us.exe $BLOBDIR/
./vbiosfinder extract $BLOBDIR/8buj25us.exe
rm $BLOBDIR/8buj25us.exe

echo "Verifying expected has of extracted roms"
cd output
echo "$W520_2000M_ROM_SHA256SUM" | sha256sum --check || { echo "2000M rom failed sha256sum verification..." && exit 1; }
echo "$W520_1000M_ROM_SHA256SUM" | sha256sum --check || { echo "1000M rom failed sha256sum verification..." && exit 1; }
echo "$IGPU_ROM_SHA256SUM" | sha256sum --check || { echo "iGPU rom Failed sha256sum verification..." && exit 1; }

echo "### Cleaning Up"
mv vbios_10de_0dda_1.rom $BLOBDIR/10de,0dda.rom
mv vbios_10de_0dfa_1.rom $BLOBDIR/10de,0dfa.rom
mv vbios_8086_0106_1.rom $BLOBDIR/8086,0106.rom
cd ..
cd ..
rm -r VBiosFinder-c2d764975115de466fdb4963d7773b5bc8468a06
cd ..
rm -r "$extractdir"

