---
title: Centos Linux 错误 “su: failed to execute /bin/bash: Resource temporarily unavailable” 解决
date: 2024-12-16 05:24:20
toc: yes
comment: true
---

# Centos Linux 错误 “su: failed to execute /bin/bash: Resource temporarily unavailable” 解决
## TLDR:

```bash
sysctl -w  kernel.pid_max=65534
echo "someuser soft nproc unlimited" >> /etc/security/limits.d/20-nproc.conf
```

## 错误现象:

在 CentOS 系统执行 `su - someuser` 命令时，无法执行，提示错误:

>  su: failed to execute /bin/bash: Resource temporarily unavailable

## 分析 & 解决

通过 `ps -eLf | wc -l` 查看当前系统总进程数量

通过 `sysctl kernel.pid_max` 查看内核允许最大进程数量，如果内核允许进程数量不足，使用以下命令修改限制：

```bash
sysctl -w  kernel.pid_max=65534
```

修改 `kernel.pid_max` 后如果错误依然存在，则可能是因为用户进程数限制导致，查看当前系统各用户的进程数:

```bash
ps h -Led -o user | sort | uniq -c | sort -n

---
      1 chrony
      2 dbus
      2 postfix
   2513 root
   4091 someuser
---
```

修改用户进程数限制:

修改 /etc/security/limits.d/20-nproc.conf 文件中，nproc 的限制:

修改前:

```
# Default limit for number of user's processes to prevent

*          soft    nproc     4096
root       soft    nproc     unlimited
```

修改后:

```
# Default limit for number of user's processes to prevent

*          soft    nproc     4096
root       soft    nproc     unlimited
someuser soft nproc unlimited
someuser hard nproc unlimited
```
