#!/bin/bash

### GCC 4.9.x
### I'm using UBERTC https://bitbucket.org/UBERTC/aarch64-linux-android-4.9-kernel

export ARCH=arm64
export PATH=/mnt/data/android/Xperia/aarch64-linux-android-4.9-kernel/bin/:$PATH

### See prefix of file names in the toolchain's bin directory
export CROSS_COMPILE=aarch64-linux-android-

export KBUILD_DIFFCONFIG=kugo_diffconfig
make msm-perf_defconfig O=/mnt/out/kernel-copyleft
time make -j8 O=/mnt/out/kernel-copyleft
