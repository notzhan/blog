---
title: Router OS 2 Wan 1 Lan Port Forwarding
date: 2024-03-29 22:12:00
toc: no
comment: true
---

# Router OS 2 Wan 1 Lan Port Forwarding

## 目标
- MikroTik ROS 路由器
- 有两个公网拨号，`pppoe-unicom`, `pppoe-cmcc`, 其中 `pppoe-cmcc` 为默认路由
- 内网服务器 `192.168.1.251:8443` 为服务端口
- 期望分别通过 `pppoe-unicom` 和 `pppoe-cmcc` 的公网地址，通过端口映射，访问内网服务器 `192.168.1.251:8443` 端口

网络拓扑如图:

![](https://files.imtxc.com/blogfiles/two-wan-one-lan-portforwarding.svg)

## 实现
1. 路由表
```bash
/routing table
add fib name=tounicom

/ip route
add dst-address=0.0.0.0/0 gateway=pppoe-unicom routing-table=tounicom
```
2. 端口映射
```bash
/ip firewall nat

# 对于默认路由，开启 dst nat 即可
add chain=dstnat in-interface=pppoe-cmcc dst-port=9000 protocol=tcp action=dst-nat to-addresses=192.168.1.8 to-ports=8443

add chain=dstnat in-interface=pppoe-unicom dst-port=9000 protocol=tcp action=dst-nat to-addresses=192.168.1.8 to-ports=8443
```
3. mangle
```bash
/ ip firewall mangle

add chain=prerouting in-interface=pppoe-unicom action=mark-connection new-connection-mark=unicom_con
add chain=output connection-mark=unicom_con action=mark-routing new-routing-mark=tounicom
add chain=prerouting connection-mark=wan2_con src-address=192.168.1.251/32 action=mark-routing new-routing-mark=tounicom
```
4. fasttrack
```bash
# 为了避免流量被 fasttrack 处理，将以下两条规则加到 fasttrack 之前
/ip firewall filter
add action=accept chain=forward connection-state=established,related src-address=192.168.1.251
add action=accept chain=forward connection-state=established,related dst-address=192.168.1.251
```

