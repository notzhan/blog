---
title: "MacOS 时间机器 没有可用的时间机器目的位置 解决"
date: 2025-08-19 04:26:55
toc: yes
comment: true
---

# MacOS 时间机器 没有可用的时间机器目的位置 解决
在 `访达` 中挂载的 SMB 存储，在 MacOS 时间机器配置中，无法配置为时间机器存储，需要在命令行操作

```bash
sudo tmutil setdestination -ap smb://smbuser:smbpasswd@smbserver_ip/TimeMachine/macmini-m4
```

或者如果是本地移动硬盘、U 盘等作为时间机器存储，可以使用

```bash
sudo tmutil setdestination -a /Volumes/xxx
```
