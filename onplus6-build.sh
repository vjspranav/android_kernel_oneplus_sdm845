#!/bin/bash

# Declaring colours
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
green='\033[0;32m'
nocol='\033[0m'

# Variables for build
TOOLCHAIN_DIR=~/toolchain/bin
KERNEL_DIR=~/op-kernel
OUT=~/out
KERN_IMG=$OUT/arch/arm64/boot/Image.gz-dtb

# Var declaration
bool=N

# Custom kernel details
KERNEL_NAME="Custom-Kernel"
DEVICE="garlic"
DATE="$(date +"%Y%m%d")"

# Usefull components for build
export ARCH=arm64
export KBUILD_BUILD_USER="vjspranav"
export KBUILD_BUILD_HOST="YU-Black"
export CCOMPILE=$CROSS_COMPILE
export CROSS_COMPILE=$(pwd)/toolchain/bin/aarch64-linux-android-

export PATH=$PATH:~/toolchain/bin
DATE_START=$(date +"%s")

cd ~/op6-kernel
rm -rf anykernel/dt.img
#rm -rf ../anykernel/modules/wlan.ko
rm -rf anykernel/zImage
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
echo -e "Making Config"
make lineage_oneplus6_defconfig O=$OUT
echo -e "Starting Build"
echo -e "$blue**************************************************************************** $nocol"
echo "                    "
echo "                                   Compiling Custom Kernel             "
echo "                    "
echo -e "$blue**************************************************************************** $nocol"
make -j32 O=$OUT
echo "Making dt.img"
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
echo "Done"

export IMAGE=$KERNEL_DIR/arch/arm64/boot/Image
if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed :P. Check errors!";
    break;
else
BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));
BUILD_TIME=$(date +"%Y%m%d-%T");
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol";
echo "Movings Files"
cd anykernel
mv $KERNEL_DIR/arch/arm64/boot/Image zImage
mv $KERNEL_DIR/arch/arm64/boot/dt.img dt.img
#mv $KERNEL_DIR/drivers/staging/prima/wlan.ko modules/wlan.ko
echo "Making Zip"
zip -r Custom-kernel-$BUILD_TIME *

fi
