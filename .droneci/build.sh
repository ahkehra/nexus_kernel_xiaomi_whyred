#!/usr/bin/env bash
set -e

# Clone dependencies
git clone https://github.com/kdrag0n/proton-clang.git --depth=1 clang
git clone --depth=1 --single-branch -b whyred https://github.com/akira-vishal/AnyKernel3.git anykernel

# Kernel Variables
KERNEL_DIR=$(pwd)
START=$(date +"%s")
DATE=$(date +"%F-%S")
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
PATH="${PWD}/clang/bin:$PATH"
CCV=$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
LDV=$(${KERNEL_DIR}/clang/bin/ld.lld --version | head -n 1)

# Setup Environtment
export ARCH=arm64
export SUBARCH=arm64
export LOCALVERSION="-p7"
export KBUILD_BUILD_HOST="droneci"
export KBUILD_BUILD_USER="akira"
export KBUILD_COMPILER_STRING="$CCV + $LDV"
if [[ "$@" =~ "oldcam" ]]; then
	export DEFCONFIG=whyred_defconfig
	export VERSION="Kernel${LOCALVERSION}-Oldcam-${DATE}"
elif [[ "$@" =~ "newcam" ]]; then
	export DEFCONFIG=whyred-newcam_defconfig
	export VERSION="Kernel${LOCALVERSION}-Newcam-${DATE}"
fi
############
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAACAgUAAx0CVxrmOQABAuqhYHYLgi-2cn9jpggMD8VYBIEzQWgAAsQBAALU8vhUZa6bA1OeOtoeBA" \
        -d chat_id=$chat_id
}
############
function info() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• Mercenary Kernel 4.4 •</b>%0ABuild started on <code>Drone CI</code>%0AFor device <b>Xiaomi Redmi Note5/5Pro</b> (whyred)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#BETA"
}
############
function push() {
    cd anykernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 5/5pro (whyred)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
############
function error() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build Throw An Error(s)"
    exit 1
}
############
function compile() {
    make O=out ARCH=arm64 $DEFCONFIG
    make -j$(nproc --all) O=out \
          ARCH=arm64 \
          CC=clang \
          LD=ld.lld \
          AR=llvm-ar \
          NM=llvm-nm \
          OBJCOPY=llvm-objcopy \
          OBJDUMP=llvm-objdump \
          STRIP=llvm-strip \
          CROSS_COMPILE=aarch64-linux-gnu- \
          CROSS_COMPILE_ARM32=arm-linux-gnueabi-

    if ! [ -a "$IMAGE" ]; then
        error
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb anykernel
}
############
function zipping() {
    cd anykernel || exit 1
    zip -r9 Nexus-Mercenary-${VERSION}.zip *
    cd ..
}
sticker
info
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
