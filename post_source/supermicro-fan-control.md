---
title: 超微主板 IPMI 风扇控制
date: 2024-04-17 20:52:00
toc: yes
comment: true
...

# 超微主板 IPMI 风扇控制

## 解决风扇转速过低导致的告警，以及风扇转速异常

```bash
# 将风扇低转速的阈值调低
ipmitool sensor thresh FANB lower 100 125 125
ipmitool sensor thresh FANA lower 100 125 125
ipmitool sensor thresh FAN1 lower 100 125 125
ipmitool sensor thresh FAN2 lower 100 125 125
```

## 使用脚本调整风扇转速

### 调速脚本

由于超微主板的自动风扇调节模式，会在 CPU 温度超过 55°时，提高风扇转速，低于 55 之后会下降，由于我的 CPU 温度在 50°左右，因此会出现风扇持续忽高忽低的跳动，因此使用以下脚本控制风扇转速，逻辑如下：
1. 先将风扇模式调整为最大（手动）模式
2. 设置三档转速：0x20 0x27 0x30 （风扇满速为 0x64, 可以根据不同风扇转速、噪音、温度控制能力调整至适合的值)
3. 每 15 秒检测一次 CPU 温度
3.1 如果 CPU 温度超过 75°，将风扇模式设置为高档，并且额外延长 5 秒降温时间
3.2 如果 CPU 温度为 65-75°，将风扇模式设置为中档
3.3 如果 CPU 温度低于 65°，将风扇模式设置为低档

```bash
#!/bin/bash

# /usr/local/bin/fan_control.sh

# 1 = low, 2 = middle, 3 = high
export CUR_FAN_SPEED_LEVEL=2

# Setting the fan control mode to manual (Full)
ipmitool raw 0x30 0x45 0x01 0x01
sleep 2

# FANA FANB
ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x20
sleep 2

get_temp() {
    sensors | grep "Tctl" | awk '{print $2}' | sed 's/+//g' | sed 's/°C//g' | awk -F. '{print $1}'
}

# if get temp failed, such as temp is null or zero, exit by code 100
TEMP=$(get_temp)
if [ -z $TEMP ] || [ $TEMP -eq 0 ]; then
    ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x20
    echo "$(date +"%F %T") Get temp failed, exit"
    exit 100
fi

while true; do
    TEMP=$(get_temp)
    if [ $TEMP -ge 75 ]; then
        if [ $CUR_FAN_SPEED_LEVEL -ne 3 ]; then
            echo "$(date +"%F %T") Temp: $TEMP Fan speed: 3"
            ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x30
            echo "I'm so hot!, let's cool down a bit"
            sleep 5
            CUR_FAN_SPEED_LEVEL=3
        fi
    elif [ $TEMP -ge 65 ]; then
        if [ $CUR_FAN_SPEED_LEVEL -ne 2 ]; then
            echo "$(date +"%F %T") Temp: $TEMP Fan speed: 2"
            ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x27
            CUR_FAN_SPEED_LEVEL=2
        fi
    else
        if [ $CUR_FAN_SPEED_LEVEL -ne 1 ]; then
            echo "$(date +"%F %T") Temp: $TEMP Fan speed: 1"
            ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x20
            CUR_FAN_SPEED_LEVEL=1
        fi
    fi
    sleep 15
done
```

### 使用 `systemd` 自动运行调速脚本
```bash
# /lib/systemd/system/fan_control.service

[Unit]
Description=Fan Controller Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/fan_control.sh
Restart=on-failure
RestartSec=5s
# StartLimitInterval=0
StartLimitInterval=1m
StartLimitBurst=10
SuccessExitStatus=100 0

[Install]
WantedBy=multi-user.target
```

## 其他
- 获取 CPU 温度
```bash
ipmitool sdr | head -1
```
- 获取转速
```bash
ipmitool sensor | grep FAN
```

- 远程 IPMI
```bash
ipmitool -H IPADDR -U username -P password -I lanplus sensor|grep FAN
```

- 执行 ipmi 命令报错 `IANA PEN registry open failed: No such file or directory`
> ipmitool sdr | head -1
> IANA PEN registry open failed: No such file or directory
```bash
wget -O /usr/share/misc/enterprise-numbers.txt https://www.iana.org/assignments/enterprise-numbers.txt
```

## ref

### <https://b3n.org/supermicro-fan-speed-script/>
