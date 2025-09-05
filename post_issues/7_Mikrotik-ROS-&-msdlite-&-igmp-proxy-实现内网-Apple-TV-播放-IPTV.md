---
title: "Mikrotik ROS & msdlite & igmp-proxy 实现内网 Apple TV 播放 IPTV"
date: 2025-09-05 02:56:43
toc: yes
comment: true
---

# Mikrotik ROS & msdlite & igmp-proxy 实现内网 Apple TV 播放 IPTV
## 概念、术语
- 组播路由: IPTV 信号是组播（Multicast）数据流。我们需要配置 IGMP Proxy，让路由器扮演一个“组播代理”的角色，代表我们的内网设备向上游网络“订阅”和“续订”我们想看的频道

- 组播转单播: 苹果生态系统（Apple TV、iOS）以及很多网页播放器对组播的支持并不好。因此，我们需要一个程序将组播流转换为更通用的 HTTP 单播流。这个角色由容器中的 msdlite（或 udpxy）来扮演。

## 前置项

- 自行确认使用联通 IPTV 机顶盒可以正常收看 IPTV 频道

- 光猫桥接模式, 我的光猫 IPTV 桥接可以桥接到每个 LAN 口，这为我们实现“单线复用”提供了物理基础

- MikroTik RouterOS 已启用 container 功能包, 用于运行 msdlite 容器


## 物理链路连接

光猫 2.5G LAN 口 <-> Mikrotik RB5009 ether1 口(用于 pppoe 拨号以及 IPTV 数据传输), 也可单独使用一个 ether 接口连接光猫 iptv 接口

Apple TV/Phone/PC <-> Mikrotik RB5009 LAN Bridge (内网网桥，可以包含下级交换机等，只需可以访问 Mikrotik LAN 口即可)


## 配置

1. Mikrotik pppoe 拨号配置与 IPTV 独立，与本文无关，略

2. Mikrotik LAN Bridge/Firewall 等配置与本文无关，略

3. 在 ether1 配置 vlan

```bash
/interface vlan add name=vlan4000-iptv vlan-id=4000 interface=ether1

# 注意：不同地区、不同运营商的 VLAN ID 可能不同（例如，其他地区可能是 45 或 85），请根据您的实际情况修改。
```

4. 给 vlan4000-iptv 配置 IP 地址, 此处配置的 IP 地址用与向光猫发送 IGMP 包时使用的源地址，可以随意配置任意的不使用的 IP 地址，比如 10.9.9.9/30, 或者简单的将它配置到 dhcp 客户端，从光猫获取一个 IP 地址, 使用 DHCP 获取地址的好处是可以通过是否能正常获取到地址来判断 vlan 等配置是否正确

```bash
/ip/dhcp-client add interface=vlan4000-iptv disabled=no

# 或者

/ip/address add inferface=vlan4000-iptv address=10.9.9.9/30
```

5. 配置 msdlite 容器

    5.1 配置 mikrotik ros 容器环境，网桥等，如果已经配置过其他容器，可以跳过, 但是一定要在容器网桥上开启 igmp-snooping, 这可以防止组播流在多个容器内泛洪。

        ```bash
        /interface bridge add name=dockers igmp-snooping=yes
        /ip address add interface=dockers address=172.16.0.1/24
        ```

    5.2 配置 msdlite 容器网卡

        ```bash
        /interface veth add name=veth-msd address=172.16.0.2/24 gateway=172.16.0.1
        /interface bridge port add interface=veth-msd bridge=dockers
        ```

    5.3 创建 msdlite 容器

        ```bash
        /container add file=msd.tar interface=veth-msd root-dir=docker/images/msd start-on-boot=yes logging=no
        /container start $MSDCONTAINER_ID
        ``````


6. 配置 igmp-proxy

```bash
/routing igmp-proxy interface add interface=vlan4000-iptv alternative-subnets=0.0.0.0/0 upstream=yes
/routing igmp-proxy interface add interface=dockers upstream=no
``````

7. 映射端口
```bash
/ip firewall/nat add chain=dstnat protocol=tcp dst-port=7088 action=dst-nat to-addresses=172.16.0.2 to-ports=7088 comment="msdlite"
```

8. 配置 mikrotik ros 防火墙，允许 vlan4000-iptv input IGMP 流量

解决 IPTV 组播转单播 iptv 每 4 分钟中断、卡顿问题, 其他人所谓的定期续订组播，其实不需要，且不优雅，因为问题的根源在于 igmp 查询包被防火墙丢弃，在大概两个 IGMP 查询周期(大约250秒)后上游认为下游不再需要组播流量，从而停止转发组播流量, 因此只要确保 msdlite, igmp-proxy 能够收到 igmp 查询包即可, msdlite 会自动发送 igmp report.


```bash
/ip/firewall filter add chain=input in-interface=vlan4000-iptv protocol=igmp action=accept comment="allow igmp from vlan4000-iptv"
```

## 客户端配置

1. 此时内网客户端可以通过 http://192.168.2.1:7088/stat 正常访问 mstlite, 此处的 192.168.2.1 为 Mikrotik LAN Bridge IP 地址

2. 内网客户端可以通过 http://192.168.2.1:7088/组播地址:端口 访问 IPTV 频道, 组播地址和端口可以通过抓包获取，或使用其他人共享的列表，如 `rtp://239.3.1.172:8001`, 则内网客户端实际访问的地址应该为 `http://192.168.2.1:7088/rtp/239.3.1.172:8001`

3. 为了在 Apple TV 等设备上方便使用，建议将频道列表整理成一个 M3U 播放列表文件, 播放列表中的每一行格式为：

```
#EXTINF:-1,频道名称
http://<ROS内网IP>:7088/rtp/组播IP:端口
```
