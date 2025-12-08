---
title: "Libvirt 配置 virtio pci legacy 支持"
date: 2025-12-08 08:35:09
toc: yes
comment: true
---

# Libvirt 配置 virtio pci legacy 支持
修改 xml， 第一行修改为
```bash
<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
```

结尾部分修改为
```bash
<qemu:commandline>
    <qemu:arg value='-global'/>
    <qemu:arg value='virtio-blk-pci.disable-modern=on'/>
    <qemu:arg value='-global'/>
    <qemu:arg value='virtio-blk-pci.disable-legacy=off'/>
		<qemu:arg value='-global'/>
    <qemu:arg value='virtio-net-pci.disable-modern=on'/>
    <qemu:arg value='-global'/>
    <qemu:arg value='virtio-net-pci.disable-legacy=off'/>
  </qemu:commandline>
</domain>
```
