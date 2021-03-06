#!/bin/bash

workdir=$(pwd)
device=kugo
vendor=sony
outputfolder=/mnt/out
outputdir=${outputfolder}/android_kernel_${vendor}_${device}


### GCC 4.9.x
### I'm using UBERTC https://bitbucket.org/UBERTC/aarch64-linux-android-4.9-kernel
export ARCH=arm64
export PATH=/mnt/data/android/Xperia/aarch64-linux-android-4.9-kernel/bin/:$PATH

### See prefix of file names in the toolchain's bin directory
export CROSS_COMPILE=aarch64-linux-android-
export KBUILD_DIFFCONFIG=kugo_diffconfig

echo "cleaning build output"
cd $outputfolder
rm -rf $outputdir
mkdir $outputdir
cd $workdir

echo "building kernel"
make msm-perf_defconfig O=$outputdir
time make -j8 O=$outputdir 2>&1 | tee ~/build.log

cd $workdir/devices/$vendor/$device/ramdisk
find . | cpio -o -H newc | gzip > $outputdir/ramdisk_kugo.cpio.gz
cd $workdir

echo "checking for compiled kernel..."
if [ -f $outputdir/arch/arm64/boot/Image.gz-dtb ]
then

    echo "DONE"

    # TBD
    # mkbootimg is going wrong - needs fixing
    # temporary workaround is to use mkboot which seems to work fine
    mkbootimg \
    --kernel $outputdir/arch/arm64/boot/Image.gz-dtb \
    --ramdisk $outputdir/ramdisk_kugo.cpio.gz \
    --cmdline "androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 zram.backend=z3fold earlyprintk" \
    --base 0x00000000 \
    --pagesize 4096 \
    --ramdisk_offset 0x22000000 \
    --tags_offset 0x00000100 \
    --output $outputdir/boot.img

    cd $outputdir
    mkboot boot.img boot
    mkboot boot boot.img
    cd $workdir

    ### Version number
	echo -n "Enter version number: "
	read version

    if [ -e $outputdir/boot.img ]
	then

        cp $workdir/devices/$vendor/$device/$device-GenesisKernel.zip $outputdir
        zip -j $outputdir/$device-GenesisKernel.zip $outputdir/boot.img

        ### Copy zip to my desktop
		dd if=$outputdir/$device-GenesisKernel.zip of=$outputdir/$device-GenesisKernel-v$version.zip
        rm $outputdir/$device-GenesisKernel.zip
    fi
fi
