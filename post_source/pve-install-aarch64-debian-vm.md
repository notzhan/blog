---
title: x86 PVE 安装 aarch64 Debian vm 虚拟机
date: 2023-01-17 21:19:15
slug: pve-install-aarch64-debian-vm
---

- 通过页面上传 arm64 Linux iso，或者在命令行拷贝到 `/var/lib/vz/template/iso/`, 如 `/var/lib/vz/template/iso/debian-11.6.0-arm64-netinst.iso`
    - 通过页面创建虚拟机
    - `General` 页面，填写虚拟机名称
    - `OS` 页面，选择 "Do not use any media", `OS-Type`: "Linux"
    - `System` 页面，`BIOS` 选择为 "OVMF(UEFI)", 同时 **取消勾选** "Add EFI Disk"
    - `Disk` 页面，按照需要的磁盘大小进行创建
    - `CPU` 页面，按照需要选择核数
    - `Memory` 内存按照需求进行配置
    - `Network` 网络使用 "VitrIO"
    - 创建完成, 得到 vmid， 如 **101**
- VM 配置页面 `Hardware` 中
    - 删除 IDE 虚拟光驱
    - 添加一个 CD/DVD 光驱，BUS 配置为 "SCSI", CD image 选择之前上传的 "debian-11.6.0-arm64-netinst.iso"
    - "SCSI Controller", 从 "VirtIO SCSI signel" 修改为 "VirtIO SCSI"
    - 添加一个 "Serial Port", "0"
    - 修改 "Display", 显卡修改为 "Serial terminal 0"
- 修改配置文件
```bash
sudo vim `find /etc/pve/nodes -name "101.conf"`
```
    - 文件开头添加一行内容 `arch: aarch64`
    - 删除 `vmgenid: ` 行
    - 添加 `boot: dcn` 行
- 创建 efi 盘
```bash
sudo apt install pve-edk2-firmware-aarch64
sudo qm set <vmid>  -efidisk0 local-lvm:1,format=raw
```
最终虚拟机配置文件内容参考
```bash
arch: aarch64
bios: ovmf
boot: dcn
cores: 2
efidisk0: local-lvm:vm-101-disk-1,size=64M
memory: 2048
meta: creation-qemu=7.1.0,ctime=1674022874
name: testdebian
net0: virtio=AA:3A:10:E2:27:01,bridge=vmbr0,firewall=1
numa: 0
ostype: l26
scsi0: local-lvm:vm-101-disk-0,iothread=1,size=32G
scsi1: local:iso/debian-11.6.0-arm64-netinst.iso,media=cdrom,size=337196K
scsihw: virtio-scsi-pci
serial0: socket
smbios1: uuid=2b72725a-31a2-4e98-9e1f-3076c9fa9001
sockets: 1
vga: serial0
```
- 启动 vm，安装系统，安装完成之后，删除 cd 光驱
- 在 Debian 中创建 EFI 启动项
```bash
 efibootmgr -c -w -L "Debian" -d /dev/sda -p 1 -l \\EFI\\debian\\grubaa64.efi 
```

### ref
[Installing and launching an ARM VM from Proxmox GUI](https://www.reddit.com/r/Proxmox/comments/ed2ldo/installing_and_launching_an_arm_vm_from_proxmox/)   
