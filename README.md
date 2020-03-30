#rootfs

## Quick Start
```
cp run_ubuntu_x86_64.sh ../
cp rootfs_ubuntu_x86_64.tar.xz
```

## build rootfs
- Get the ubuntu-base-18.04-base-amd64.tar.gz
```
http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.3/release/ubuntu-base-18.04-base-amd64.tar.gz
```

- Unpack and Mount
```
sudo tar xvf ubuntu-base-18.04-base-amd64.tar.gz -C rootfs_ubuntu_x86_64
sudo ./mount.sh -m rootfs_ubuntu_x86_64/
```

- Copy宿主机的/etc/resolve.conf文件
```
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 114.114.114.114
nameserver 8.8.8.8
```
- Operation in rootfs
```
# apt update
# apt install systemd (init process)
# apt install vim
# apt install ifupdown/netplan
# apt install iputils-ping
# apt install pciutils
# atp install module-init-tools
```
- set hostname, user, password
- compress rootfs-ubuntu-x86-64
```
sudo tar cfv rootfs_ubuntu_x86_64.tar rootfs_ubuntu_x86_64
```


## Problems

Fixed the following problems:

        1. During boot, Kernel is stuck with the information looks like so:
           *Time out waiting for the device dev-ttyAMA0.device.*
           Solution: Change *BindsTo=dev-%i.device* to *BindsTo=dev-%i*
           in $rootfs_path/lib/systemd/system/serial-getty\@.service

        2. Problem: Kernel enter the bash command directly without login.
           Solution: apt install systemd. Without systemd kernel runs */bin/sh*
           and enter the bash command directly.

        3. Share files between host and VM, enable the following
           build configuration options:
                CONFIG_NET_9P=y (defconfig)
                CONFIG_9P_FS=y  (defconfig)
                CONFIG_VIRTIO_PCI=y (defconfig)
                CONFIG_NET_9P_VIRTIO=y (defconfig)
		CONFIG_9P_FS_POSIX_ACL=y (add manually)
                CONFIG_NET_9P_DEBUG=y (Optional)

	4. Connect to internet
           Solution: apt install ifupdown/netplan


