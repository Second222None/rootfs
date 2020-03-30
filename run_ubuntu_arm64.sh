#!/bin/bash

LROOT=$PWD
JOBCOUNT=${JOBCOUNT=$(nproc)}
#export ARCH=arm64
#export CROSS_COMPILE=aarch64-linux-gnu-
export INSTALL_PATH=$LROOT/rootfs_ubuntu_arm64/boot/
export INSTALL_MOD_PATH=$LROOT/rootfs_ubuntu_arm64/
export INSTALL_HDR_PATH=$LROOT/rootfs_ubuntu_arm64/usr/

rootfs_path=$PWD/rootfs_ubuntu_arm64
rootfs_image=$PWD/rootfs_ubuntu_arm64.ext4
kernel_build=$rootfs_path/usr/src/linux/

SMP="-smp 4"

if [ $# -lt 1 ]; then
	echo "Usage: $0 [arg]"
	echo "build_kernel: build the kernel image."
	echo "build_rootfs: build the rootfs image."
	echo " run:  run ubuntu system."
fi

if [ $# -eq 2 ] && [ $2 == "debug" ]; then
	echo "Enable qemu debug server"
	DBG="-s -S"
	SMP=""
fi

make_kernel_image(){
		echo "start build kernel image..."
		make enable_all_defconfig
		make -j $JOBCOUNT
}

prepare_rootfs(){
		if [ ! -d $rootfs_path ]; then
			echo "decompressing rootfs..."
			xz -d rootfs_ubuntu_arm64.tar.xz -k
			tar xf rootfs_ubuntu_arm64.tar
		fi
}

build_kernel_devel(){
	kernver="$(make -s kernelrelease)"
	echo "kernel version: $kernver"

	mkdir -p $kernel_build
	rm $rootfs_path/lib/modules/$kernver/build
	cp -a include $kernel_build
	cp Makefile .config Module.symvers System.map vmlinux $kernel_build
	mkdir -p $kernel_build/arch/arm64/
	mkdir -p $kernel_build/arch/arm64/kernel/

	cp -a arch/arm64/include $kernel_build/arch/arm64/
	cp -a arch/arm64/Makefile $kernel_build/arch/arm64/
	cp arch/arm64/kernel/module.lds $kernel_build/arch/arm64/kernel/

	ln -s /usr/src/linux $rootfs_path/lib/modules/$kernver/build

	ln -s /usr/src/linux-kbuild/scripts $rootfs_path/usr/src/linux/scripts
	ln -s /usr/src/linux-kbuild/tools $rootfs_path/usr/src/linux/tools
}

check_root(){
		if [ "$(id -u)" != "0" ];then
			echo "superuser privileges are required to run"
			echo "sudo ./run_ubuntu_arm64.sh build_rootfs"
			exit 1
		fi
}

build_rootfs(){
		if [ ! -f $rootfs_image ]; then
			make install
			make modules_install -j $JOBCOUNT
			make headers_install

			build_kernel_devel

			echo "making image..."
			dd if=/dev/zero of=$rootfs_image bs=1M count=8192
			mkfs.ext4 $rootfs_image
			mkdir -p tmpfs
			echo "copy data into rootfs..."
			mount -t ext4 $rootfs_image tmpfs/ -o loop
			cp -af $rootfs_path/* tmpfs/
			umount tmpfs
			chmod 777 $rootfs_image
		fi

}

run_qemu_ubuntu(){
		mkdir -p $PWD/kmodules

		qemu-system-aarch64 -enable-kvm -m 4096 -cpu host  -M virt\
			-nographic $SMP -kernel arch/arm64/boot/Image \
			-append "noinintrd root=/dev/vda rootfstype=ext4 rw crashkernel=256M loglevel=8" \
			-drive if=none,file=$rootfs_image,id=hd0,format=raw \
			-device virtio-blk-pci,scsi=off,drive=hd0 \
			-netdev user,id=nd0 \
			-device virtio-net-pci,netdev=nd0\
			-fsdev local,id=kmod_dev,path=./kmodules,security_model=none \
			-device virtio-9p-pci,fsdev=kmod_dev,mount_tag=kmod_mount\
			$DBG

}

case $1 in
	build_kernel)
		make_kernel_image
		#prepare_rootfs
		#build_rootfs
		;;
	
	build_rootfs)
		#make_kernel_image
		check_root
		prepare_rootfs
		build_rootfs
		;;
	run)

		if [ ! -f $LROOT/arch/arm64/boot/Image ]; then
			echo "canot find kernel image, pls run build_kernel command firstly!!"
			exit 1
		fi

		if [ ! -f $rootfs_image ]; then
			echo "canot find rootfs image, pls run build_rootfs command firstly!!"
			exit 1
		fi

		#prepare_rootfs
		#build_rootfs
		run_qemu_ubuntu
		;;
	clean)
#		make mrproper
		rm -rf $rootfs_path
		rm -rf $rootfs_image
esac

