---
title: HP 1020 plus airprint 打印服务器配置
date: 2021-04-04 20:24:22
slug: home-printer-server-hp1020plus
---

### Tips

p910nd 和 cups 都有将 usb 打印机共享到网络中的功能, p910nd 不支持 ios，cups 对设备 ram 要求稍高, 因此:

1. 如果家中只有 windows 和安卓设备，只需要配置 p910nd
2. 如果家中有可以 24 小时开机并且 ram 大于 1G 并且带有 USB 口的设备，只需要配置 cups

### Why

捡垃圾买了了 300 元的 hp1020plus 打印机，它的稳定性和耗材价格都非常不错，但是缺点就是它只有 USB 打印功能，不支持网络打印以及 IOS 系统的 Airprint 功能，就简单的拿之前淘汰下来的 NEXX 3020F 路由器配置了下，做了个远程打印服务器。

理论上所有带有 USB 口的可以刷 Openwrt 系统的设备都可以使用这种方式。

### 硬件

- HP 1020 Plus 打印机一台

- 带有 USB 口的 Openwrt 路由器一台

### 软件

- Openwrt, 由于路由器的 RAM 一般都比较小，但是直接使用 cups 做打印服务器需要使用较大的资源，因此 Openwrt 系统源里面
现在已经不包含 cups 组件了。

- 任意一台 24 小时开机的 Linux 设备一台, 用于安装 CUPS 搭建 Airprint Server 使用, 如果不使用 IOS 设备，就不需要 CUPS

### HowTo:

#### Openwrt (p910nd 打印服务器)

1. 在任意安装了 Openwrt 系统带有 USB 口的设备上, 将打印机的 USB 线接到 Openwrt 系统上，使用 root 用户登录，执行以下命令:

```bash
sed -i 's_downloads.openwrt.org_mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg/distfeeds.conf # 配置国内源，加快后续安装的速度
opkg update ## 更新源
opkg install kmod-usb-printer luci-i18n-base-zh-cn kmod-usb-printer luci-app-p910nd p910nd # 安装所需要的组建
wget -O /etc/sihp1020.dl http://oleg.wl500g.info/hplj/sihp1020.dl ## 下载 hp1020plus 打印机的 firmware
cat /etc/sihp1020.dl > /dev/usb/lp0 ## 将打印机的固件发送到打印机，这步执行完之后打印机应该会有工作的声音发出。
```

以上就安装好了所有需要的组建和固件，可以从 [http://oleg.wl500g.info/hplj/](http://oleg.wl500g.info/hplj/) 下载其他型号的固件。

由于 hp 1020 plus 打印机本身不带固件，因此每次开机之后，都需要将下载下来的 `sihp1020.dl` cat 到打印机，因此我们写一个 usb hotplug 的
脚本，在每次打印机开机或者 openwrt 重启之后，自动将固件发送到打印机:

添加文件 `/etc/hotplug.d/usb/10_usb-printer`, 内容如下:

```bash
#!/bin/sh
set -e

# change this to the location where you put the .dl file:
FIRMWARE=/etc/sihp1020.dl
DEVICE=/dev/usb/lp0
LOGFILE=/tmp/hp1020

if [ "$PRODUCT" = "3f0/2b17/100" ]; then
        case "$ACTION" in
                add)
                        # /etc/init.d/p910nd stop
                        echo "`date '+%Y-%m-%d %H:%M:%S'`: HP LaserJet 1020 added" >> $LOGFILE
                        # /etc/init.d/p910nd start >> /tmp/hp1007
                        echo "`date '+%Y-%m-%d %H:%M:%S'`: STARTING" >> $LOGFILE
                        for i in $(seq 30); do
                                echo "`date '+%Y-%m-%d %H:%M:%S'`: Attempt Number $i on $DEVICE" >> $LOGFILE
                                if [ -c $DEVICE ]; then
                                        echo "`date '+%Y-%m-%d %H:%M:%S'`: Device $DEVICE found" >> $LOGFILE
                                        if [ -z "`usb_printerid $DEVICE | grep FWVER`" ]; then
                                                echo "`date '+%Y-%m-%d %H:%M:%S'`: No firmware found on $DEVICE" >> $LOGFILE
                                                echo "`date '+%Y-%m-%d %H:%M:%S'`: Sending firmware to printer..." >> $LOGFILE
                                                cat $FIRMWARE > $DEVICE
                                                echo "`date '+%Y-%m-%d %H:%M:%S'`: Done" >> $LOGFILE
                                        else
                                                echo "`date '+%Y-%m-%d %H:%M:%S'`: Firmware already there on $DEVICE" >> $LOGFILE
                                        fi
                                        echo "`date '+%Y-%m-%d %H:%M:%S'`: EXITING" >> $LOGFILE
                                        exit
                                fi
                                sleep 1
                        done
                        echo "`date '+%Y-%m-%d %H:%M:%S'`: Done" >> $LOGFILE
                        ;;
                remove)
                        echo "`date '+%Y-%m-%d %H:%M:%S'`: HP LaserJet 1020 removed" >> $LOGFILE
                        # /etc/init.d/p910nd stop >> /tmp/hp1007
                        echo "`date '+%Y-%m-%d %H:%M:%S'`: Done" >> $LOGFILE
                        ;;
        esac
fi
```

2. 刷新 Openwrt 配置页面，进入 “服务 - p910nd Printer server”, 勾选 `Enable`, 接口配置为 `lan`, 端口 `9100`, 取消 `Bidirectional mode (双向模式)`
前面的勾，点击 “保存并应用”.

3. 进入 "网络 - 防火墙 - Traffic Rules", 新增一条流量规则，允许本地网络连接 9100 端口:

```bash
名称: printer
协议: TCP
Source Zone: lan
Source address: 不用选择
Source port: 任意
目标区域: 设备（输入)
Destination address: 不用选择
Destination port: 9100
Action: accept
```

然后点击 "保存"，再点击 “保存并应用”

至此，Openwrt 上面的 p910nd 服务器已经配置完成，可以正常的在 Windows，Linux 和 Android (需要 printhand APP) 设备上使用了, 但是
如果需要在 IOS 设备上使用，就需要使用 cups 来作为 airprint 服务器。

#### Any Linux (cups as airprint server)

```bash
apt install cups printer-driver-foo2zjs hplip ## 安装所需的包和驱动
sudo usermod -a -G lpadmin zhan ### 这里的 xxx 为登录 linux 的用户名，在浏览器里配置 cups 需要登录
```

然后修改 `/etc/cups/cupsd.conf`

```bash
Browsing Off 修改为 Browsing On
```

```bash
Listen localhost:631 修改为 Listen 631
```

```bash
<Location />
  Order allow,deny
  Allow all
</Location>
```

```bash
<Location /admin>
  Order allow,deny
  Allow all
</Location>
```

然后执行:

```bash
systemctl restart cups
```

然后执行以下步骤:

1. 在浏览器中打开 `https://ipadder:631`
1. 点击 `Administration` - `Add Printer`,  输入登录系统并且已经加到 lpadmin 组的账户的用户名密码
1. 选择 `AppSocket/HP JetDirect` - `Continue`
1. `Connection` 中输入 `socket://openwrtip:9100` - `Continue`
1. 给最终 share 的打印机取名，必须勾选 `Share This Printer` - `Continue`, 这一步 ** 非常重要 ** , 这里填写的名字，是
以后在 windows 中添加打印机的 uri, 必须勾选共享选项局域网中别的设备才可以发现这台打印机。
1. 打印机品牌选择 hp - `continue`
1. 打印机型号选择 `HP LaserJet 1020 Foomatic/foo2zjs-z1 (recommended)` - `Add Printer`

如图，cups 的配置就已经完成了。

![](https://static.yangsite.com/img/hp1020cups.png)

#### 客户端配置

##### IOS
iphone， ipad 等 ios 设备这时已经可以使用打印功能了，不需要做其他额外的配置和安装其他 app。

#### Windows

Windows 可以使用两种方式添加打印机，既可以添加 p910nd 设备，也可以添加刚才共享的 cups 设备。

#### Linux
Linux 设备可以参考上述步骤，安装 cups，同时可以跳过修改配置文件的步骤，直接参考添加打印机的步骤即可。

### 总结:

以上，家中需要的打印方案就算解决完成了，hp1020plus 没有扫描仪，需要扫描/复印的话需要在其他扫描仪上将文档扫描成 pdf，然后发送到手机，直接通过手机打印。 

如果家里有 24 小时开机的 RAM 超过 1G 同时有 USB 口的设备, 如 N1 盒子、XX 云盒子之类，可以直接使用 cups 参考以上步骤解决问题, 以上 p910nd 和 cups 组合的方案只是由于特殊原因才变得复杂了(可以安装 cups 的设备没有 USB 接口).

### Ref:

1. [https://openwrt.org/docs/guide-user/services/print\_server/p910nd.server](https://openwrt.org/docs/guide-user/services/print_server/p910nd.server)
2. [https://www.right.com.cn/forum/thread-4050057-1-1.html](https://www.right.com.cn/forum/thread-4050057-1-1.html)
