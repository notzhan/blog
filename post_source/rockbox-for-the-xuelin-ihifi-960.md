---
title: 在学林 iHiFi960 上刷 Rockbox
Slug: rockbox-for-the-xuelin-ihifi-960-primer-zhcn
date: 2015-11-29 16:20:00
Category: post
Tags:
- hifi
- music
---

[原贴链接](http://www.head-fi.org/t/768396/rockbox-for-the-xuelin-ihifi-960-a-primer)

#### 相关说明

* 刷 Rockbox 是可逆的，可以刷回原厂固件
* 刷 Rockbox 之后，只能使用 tf 卡，无法在 rockbox 中访问 960 内置存储(刷回原厂固件可以恢复)
* 原作者和转发者均不对意外刷机导致的损坏负责 ^^

#### 需要准备的环境/硬件

* 最好有 usb2.0 的 xp 或者 win7 系统
* tf 卡和读卡器
* mini usb 数据线
* 充满电的学林 iHiFi960

#### 需要准备的文件

1. 刷机工具和驱动，可以从学林网站获得: http://www.91avr.com/ihifiupimg.rar
2. Rockbox 固件: 原作者上传在 google driver, 由于下载不方便，加了一个国内[分享链接](http://pan.baidu.com/s/1qWxjjGw), 解压得到 `ihifi960_rb.img` 文件
3. Rockbox Daily Build: [http://www.rockbox.org/dl.cgi?bin=ihifi960](http://www.rockbox.org/dl.cgi?bin=ihifi960), 下载日期最新的.

#### 安装驱动

安装驱动的方式和升级学林原厂固件的方式相同，参考 `ihifiupimg.rar` 中的 `固件升级注意事项.doc` 中的说明.

> Note: 在 win7 系统中，如果使用 usb3.0 接口，可能会出现 ”找不到 rk27 设备“, 可以尝试将 960 连接到 usb2.0 口.

#### 刷 Rockbox 固件

1. 参考学林教程 `固件升级注意事项.doc` 中的方式，但是在选择固件 image 的时候，这里需要选择从[这里](http://pan.baidu.com/s/1qWxjjGw) 下载到的 `ihifi960_rb.img` 文件
2. 点击 `升级` 按钮开始升级到 Rockbox 固件.
3. 升级结束后, 可以在 960 的屏幕顶部看到几行输出.
4. 关闭 960 的电源(使用电源拨杆).

#### 将 Daily Build 解压到 tf 卡中

1. 解压从 http://www.rockbox.org/dl.cgi?bin=ihifi960 获取到的最新的 Rockbox Daily Build, 得到 `.rockbox` 目录
2. 将得到的 .rockbox 目录通过读卡器拷贝到 tf 卡的根目录中(不要删除目录名称中的 `.`).
3. 将 tf 卡装入 960, 打开 960 电源并且长按播放按钮开机.
5. 在闪过 Rockbox logo 之后，会进入 Rockbox 系统.

#### 中文设置

Rockbox 默认没有中文字体，显示中文歌曲名称等会出现方块, 解决方式: 

1. 下载中文字体 `16-GNU-Unifont.fnt`
2. 使用读卡器，将 `16-GNU-Unifont.fnt` 拷贝到 tf 卡根目录下的 `.rockbox` 目录中的 `fonts` 目录中
3. `Settings–Theme Settings–Font`，选择 `16-GNU-Unifont`, 这样已经可以正确的显示中文音乐文件名称
4. `Settings–General Settings–Display–Default Codepage`, 选择 `Simp. Chinese (GB2312)` 或者 `Unicode (UTF-8)`
5. `Settings–General Settings–Language`, 选择 `chinese-simp`

#### 恢复原厂固件

如果想恢复到学林原厂固件，只需要完全按照学林`固件升级注意事项.doc` 中的说明升级到最新原厂固件即可.
