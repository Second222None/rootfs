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
- Operation in rootfs
```
# apt update
# apt install vim
# apt install ifupdown/netplan
# apt install iputils-ping
# apt install pciutils
# atp install module-init-tools
```
- 压缩rootfs-ubuntu-x86-64
```
sudo tar cfv rootfs_ubuntu_x86_64.tar rootfs_ubuntu_x86_64
```

