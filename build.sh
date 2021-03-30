#!/bin/bash
#
# Script For Building Android Kernel By akira-vishal
#
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0m'
GREY='\e[0;32m'
GREEN='\e[1;32m'
KERNEL_DIR=$PWD
TANGGAL=$(date +"%F-%S")
DATE=$(date +"%m-%d-%y")
START=$(date +"%s")
DEVICE=WhyRed
DEFCONFIG=whyred_defconfig
#
# use ccache
export USE_CCACHE=1
#
#ccache variables
export CCACHE_DIR="$HOME/.ccache"
export CC="ccache gcc"
export CXX="ccache g++"
export PATH="/usr/lib/ccache:$PATH"
#
#Export variables
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export LOCALVERSION="-X3"
export KBUILD_COMPILER_STRING="$(gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_BUILD_HOST="akira"
export KBUILD_BUILD_USER="vishal"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
#
function checker() {
    if [ -f $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb ]
       then
        echo -e ""
        echo -e "$CYAN- Cloning AnyKernel3$WHITE"
        cd && git clone https://github.com/akira-vishal/AnyKernel3.git AnyKernel
        echo -e ""
        echo -e "$GREEN- Done!$WHITE"
        cd $HOME && cd $KERNEL_DIR
        zipper
       else
        echo -e ""
        echo -e "$RED- Build Failed$WHITE"
        
    fi
}
#
function zipper() {
    rm -f $HOME/AnyKernel/Image.gz*
    rm -f $HOME/AnyKernel/zImage*
    rm -f $HOME/AnyKernel/dtb*
    echo -e ""
    echo -e "$CYAN- Time To ZIP Up!$WHITE"
    cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $HOME/AnyKernel
    cd $HOME/AnyKernel || exit 1
    zip -r9 neXus-X3_${DEVICE}-KERNEL-${TANGGAL}.zip *
    cd $HOME && cd $KERNEL_DIR
    END=$(date +"%s")
    DIFF=$(($END - $START))
    echo -e ""
	echo -e "$GREEN- Build Completed Succesfully$WHITE"
	echo -e ""
	echo -e "$GREEN- Build took : $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).$WHITE"
	echo -e ""
}
#
function compiler() {
    rm -rf $KERNEL_DIR/out
    echo -e ""
	echo -e "$CYAN- Building Kernel$WHITE"
    make clean && make mrproper O=out
    make O=out	${DEFCONFIG}
    make -j$(nproc --all) O=out
}
compiler
checker
