---
title: "使用 USB/IP 共享 USB 设备"
date: 2024-12-16 10:41:10
toc: yes
comment: true
---

# 使用 USB/IP 共享 USB 设备
## 服务端

### Windows
#### 1. 下载 [usbipd-win](https://github.com/dorssel/usbipd-win/releases/) 并安装 `usbip windows server`

#### 2. 使用管理员权限启动 Powershell

#### 3. 列出当前设备上的 USB 设备

```bash
usbipd list
```

输出

```
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-7    046d:c52b  Logitech USB Input Device, USB 输入设备                       Not shared
1-8    8087:0026  英特尔(R) 无线 Bluetooth(R)                                   Not shared
2-4    0b95:1790  ASIX USB to Gigabit Ethernet Family Adapter                   Not shared
3-1    20a0:42d4  USB 输入设备, WebUSB, Microsoft Usbccid Smartcard Reader ...  Not shared
3-3    0483:5026  USB 输入设备
```

#### 4. 共享指定的 USB 设备 (BUSID)

```bash
usbipd bind  -b 3-1
```

#### 5. 再次使用 `usbipd list` 命令查看设备，可以看到指定的设备是 `Shared` 的状态，如下

```
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-7    046d:c52b  Logitech USB Input Device, USB 输入设备                       Not shared
1-8    8087:0026  英特尔(R) 无线 Bluetooth(R)                                   Not shared
2-4    0b95:1790  ASIX USB to Gigabit Ethernet Family Adapter                   Not shared
3-1    20a0:42d4  USB 输入设备, WebUSB, Microsoft Usbccid Smartcard Reader ...  Shared   << 该设备被共享
3-3    0483:5026  USB 输入设备
```

#### 6. 结束共享

```bash
usbipd unbind -a
```

## 客户端

### Linux

#### 1. 安装 usbip

```bash
sudo apt install usbip
```

#### 2. 查看服务端共享的 usb 设备列表

```bash
sudo usbip list -r 192.168.12.23
```
输出如下：
```
Exportable USB devices
======================
 - 192.168.12.23
        3-1: Clay Logic : unknown product (20a0:42d4)
           : USB\VID_20A0&PID_42D4\0.......
           : (Defined at Interface level) (00/00/00)
           :  0 - Human Interface Device / No Subclass / None (03/00/00)
           :  1 - Vendor Specific Class / Vendor Specific Subclass / Vendor Specific Protocol (ff/ff/ff)
           :  2 - Chip/SmartCard / unknown subclass / unknown protocol (0b/00/00)
```

#### 3. 加载服务端共享的 usb 设备

```bash
sudo usbip attach  -r 192.168.12.23 -b 3-1
```

#### 4. 列出当前系统上加载的远程 usb 设备

- 使用 usbip 命令

```bash
sudo usbip port
```

输出
```
Imported USB devices
====================
Port 00: <Port in Use> at Full Speed(12Mbps)
       Clay Logic : unknown product (20a0:42d4)
      11-1 -> usbip://192.168.12.23:3240/3-1
           -> remote bus/dev 003/001
```

- dmesg 命令输出
```
[114820.288560] vhci_hcd vhci_hcd.0: Device attached
...
[114820.889895] usb 11-1: New USB device found, idVendor=20a0, idProduct=42d4, bcdDevice= 1.00
[114820.890580] usb 11-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
...
```

- lsusb 输出
```
lsusb -s 011:003
Bus 011 Device 003: ID 20a0:42d4 Clay Logic CanoKey Pigeon
```

通过以上 usbip port、dmesg 和 lsusb 输出可以看到物理连接在服务端上的 usb 设备 "CanoKey Pigeon" 已经可以在当前 Linux 端使用。

#### 5. 卸载远程 usb 设备

```bash
sudo usbip detach -p 00

# 此处的 00 即 usbip port 命令输出中的 Port 值
```

## 错误解决

- libusbip: error: udev_device_new_from_subsystem_sysname failed
```bash
sudo modprobe vhci-hcd
```
