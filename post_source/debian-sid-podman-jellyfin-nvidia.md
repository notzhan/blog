---
title: Debian Podman 安装 Jellyfin，并且配置 nvidia T400 显卡解码
date: 2023-04-05 12:10:15
toc: true
---

## 安装 nvidia 显卡驱动，以及 nvidia-container-toolkit
```bash
cat <<EOF |sudo tee /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free non-free-firmware
deb [trusted=yes] https://nvidia.github.io/libnvidia-container/stable/debian11/amd64 /
EOF
sudo apt update
sudo apt install nvidia-cuda-dev nvidia-cuda-toolkit nvidia-driver firmware-misc-nonfree
sudo apt install libnvidia-container-tools libnvidia-container1 \
 nvidia-container-toolkit nvidia-container-toolkit-base
```

安装完成之后使用 `nvidia-smi` 命令查看输出如下:

```bash
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.89.02    Driver Version: 525.89.02    CUDA Version: 12.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA T400 4GB     On   | 00000000:C1:00.0 Off |                  N/A |
| 38%   41C    P8    N/A /  31W |      1MiB /  4096MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

## 配置 nvidia container toolkit

```bash
sudo mkdir -p /usr/share/containers/oci/hooks.d 
cat <<EOF | sudo tee /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json
{
    "version": "1.0.0",
    "hook": {
        "path": "/usr/bin/nvidia-container-runtime-hook",
        "args": ["nvidia-container-runtime-hook", "prestart"],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ]

     },
     "when": {
     "always": true,
     "commands": [".*"]
     },
     "stages": ["prestart"]
}
EOF

sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml
```

## nvidia-uvm modules 自动加载

```bash
cat <<EOF | sudo tee /etc/udev/rules.d/61-nvidia-uvm.rules
DRIVER=="nvidia", RUN+="/usr/bin/nvidia-modprobe -c0 -u"
EOF
```

## jellyfin

```bash
podman run -d --name jellyfin -p 8096:8096 \
-v /path/to/media:/media:ro \
-v /path/to/jellyfin/config:/config \
--device nvidia.com/gpu=all \
--device /dev/nvidia-uvm \
--device /dev/nvidia-uvm-tools \
jellyfin/jellyfin
```

### 转码配置

![Jellyfin 转码配置](https://files.imtxc.com/blogfiles/jellyfin1.png)
![Jellyfin 转码配置](https://files.imtxc.com/blogfiles/jellyfin2.png)

### 中文字体配置

1. 下载 woff2 格式中文字体到 host
2. 使用 volume 映射到 container 中, 如 `-v /path/to/fonts:/config/fonts`
3. Jellyfin - 控制台 - 播放 - 勾选 “启用备用字体”
4. Jellyfin - 控制台 - 播放 - “备用字体文件路径” 中，输入映射到 container 中的路径，如 `/config/fonts/`
5. 保存配置
