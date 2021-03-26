#!/bin/bash
#
# Script For Building Android Kernel By akira-vishal
#
KERNEL_DIR=$PWD
TANGGAL=$(date +"%F-%S")
DATE=$(date +"%m-%d-%y")
START=$(date +"%s")
DEVICE=WhyRed
DEFCONFIG=whyred-oldcam_defconfig
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
#
# use ccache
export USE_CCACHE=1
#
#ccache variables
export CCACHE_DIR="$HOME/.ccache"
export CC="ccache gcc"
export CXX="ccache gcc++"
export PATH="/usr/lib/ccache:$PATH"
#
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
#
#Export ARCH <arm, arm64, x86, x86_64>
export ARCH=arm64
#
#Export SUBARCH <arm, arm64, x86, x86_64>
export SUBARCH=arm64
#
#Set kernal name
export LOCALVERSION=-X3
#Export Username
export KBUILD_BUILD_USER=VISHAL
#Export Machine name
export KBUILD_BUILD_HOST=AKIRA
#
function checker() {
    if [ -f $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb ]
       then
        echo -e "\e[1;32mCloning AnyKernel3\e[0m"
        cd && git clone https://github.com/akira-vishal/AnyKernel3.git AnyKernel
        echo -e "\e[1;32mDone!\e[0m"
        cd $HOME && cd $KERNEL_DIR
        zipper
       else
        echo -e "\e[1;32mBuild failed\e[0m"
    fi
}
#
function zipper() {
    rm -f $HOME/AnyKernel/Image.gz*
    rm -f $HOME/AnyKernel/zImage*
    rm -f $HOME/AnyKernel/dtb*
    echo -e "\e[1;32mTime To ZIP Up!\e[0m"
    cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $HOME/AnyKernel
    cd $HOME/AnyKernel || exit 1
    zip -r9 neXus-X3_${DEVICE}-KERNEL-${TANGGAL}.zip *
    cd $HOME && cd $KERNEL_DIR
    END=$(date +"%s")
    DIFF=$(($END - $START))
    echo -e "\e[1;32mBuild Completed Succesfully\e[0m"
    echo -e "\e[1;32mBuild took : $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).\e[0m"
}
#
function compiler() {
    rm -rf $KERNEL_DIR/out
    echo -e "\e[1;32mBuilding Kernel\e[0m"
    make clean && make mrproper O=out
    make O=out	${DEFCONFIG}
    make O=out -j$(nproc --all) 
}
compiler
checker
