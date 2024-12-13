---
title: SATA 3.3 的 Power Disable Feature
date: 2018-09-30 16:19:22
slug: sata-power-disable-pin
---

从两块西部数据的 My Book 桌面硬盘中拆出硬盘打算在 NAS 中使用，结果两块硬盘中的一块，在我的 NAS 上无法识别，记录一下解决方式.

### 原因
在旧的 SATA Spec 中，Sata 使用 15 pin 的电源线供电，其中的 p1-p3 是 3.3V 供电, p4-p6 是接地，
p7-p9 是 5V 供电， p13-p15 是 12V 供电，由于 3.3V 供电已经不在 sata 硬盘上面使用，因此大多数硬盘
的 p1-p3 脚是没有使用的，有部分的 sata 供电线也会把 p1-p3 留空.

SATA 数据线和电源线的定义如下:

![](https://files.imtxc.com/blogfiles/sata-power-cable-spec.jpg)

但是，在 sata spec v3.3 中，新增加了一个定义，叫做 **Power Disable**, 定义如下:

> Power Disable: Allows for remote power cycling of SATA drives to help ease maintenance in the
data center. 

SATA 3.3 中，增加了 Power Disable 定义，使用 SATA 供电的 Pin3 脚，如果在 Pin3 上有高电平，就会打开
硬盘的 Power Disable 功能，这时候，硬盘不会启动.

在 HGST 的网站中有如下的介绍:

> * SATA Specification Revision 3.1 and prior revisions assigned 3.3V to pins P1, P2 and P3.
In addition, device plug pins P1, P2, and P3 were required to be bused together. In the
standard configuration of this product, P3 is connected with P1 and P2 and this product
behaves as a SATA version 3.1 or prior device. For product with the optional SATA 3.3
Power Disable Feature supported, P3 is now assigned as the POWER DISABLE CONTROL
PIN. If P3 is driven HIGH (2.1V-3.6V max), power to the drive circuitry will be disabled. Drives
with this optional feature WILL NOT POWER UP in systems designed to SATA Spec Revision
3.1 or earlier. This is because P3 driven HIGH will prevent the drive from powering up.

### 解决方案

**由于这个原因，如果在支持新的 SATA SPEC 的硬盘上面，使用老旧的 sata 供电线路，就会导致触发 Power Disable
 功能而无法启动硬盘的问题.**

因此，要还在老的设备上使用支持了最新标准的 SATA 硬盘，就需要做一些处理:

1. 使用大 4D 转 sata 电源线供电，由于大 4D 转 sata 电源线没有在 Pin3 脚接线，因此不会启动硬盘的  power disable

2. 剪线，剪掉 sata 供电线的 pin3 那条线

3. 是我目前使用的方式，由于我的 NAS 上使用了一个很旧的 SATA 背板，没有办法剪线，所以，最简单的处理方式，就是
使用透明胶带吧 sata 硬盘的供电 Pin 3 那个引脚粘起来，不会影响插拔硬盘。要是手粗一点，把 p1-p3 这三个脚全粘起来其实
也不会有问题。


### ref
[HGST Power Disable Pin](https://www.hgst.com/sites/default/files/resources/HGST-Power-Disable-Pin-TB.pdf)   
[SATA Spec V3.3](https://sata-io.org/sites/default/files/documents/SATA%20Spec%203%203%20Press%20Release_FINAL.pdf)

