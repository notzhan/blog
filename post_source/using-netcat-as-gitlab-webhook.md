---
title: 使用 netcat 作为 gitlab 的 webhook
date: 2018-08-18 17:10:10
slug: using-netcat-as-gitlab-webhook
---

### 关于 netcat

> nc - TCP/IP swiss army knife  
> arbitrary TCP and UDP connections and listens

netcat 号称网络工具中的 ”瑞士军刀“，可以运行在 TCP 和 UDP 下，在网络开发/调试过程中，可以作为
一个简易又全功能的 Client 和 Server 使用，与其他工具配合, 可以在网络测试作为很重要的作用。

### Gitlab Webhook 介绍

Gitlab 支持使用 Gitlab CI 和 Webhook 两种自动化部署方式，使用 Gitlab CI 的方式需要安装 
gitlab multi runner 以及配置 `.gitlab-ci.yml` 文件来控制部署流程，对于简单的项目部署，可以使用
Webhook 的方式快捷的做自动化集成/部署。

#### gitlab webhook 原理

简单说， Gitlab webhook 就是我们在 Gitlab 上的 repo 中执行 Push, Comments, Merge request 等操作
后，向指定的 URL 发送一个 POST 请求, 我们只需要在 Server 上面监听这个 POST 请求并且调用部署脚本就
可以实现对 gitlab 上的 Project 进行自动化部署。

#### Gitlab webhook handler

有很多开源的 gitlab webhook handler 可以直接使用，不过如果不需要进行其它更复杂的操作，只是监听
POST 请求并且进行下一步的处理，这是 netcat 工具的强项，因此这里使用 netcat 来进行监听。

### 使用 Gitlab Webhook

#### 在有公网 IP 的虚拟机/Server 上启用 netcal http listen

首先使用 Gitlab Webhook 需要有一个可以让 gitlab 服务器访问到的服务器/虚拟机，先使用最简单的命令监听
POST 请求, 向客户端返回 HTTP 200 从信息，并且打印提示信息:

``` bash
echo -e "HTTP/1.1 200 OK\r\n" | nc -l -p 12121; echo "OK"
```

这里的 `-p 12121` 是指定监听端口号.

然后任意的机器上面使用 wget 命令来测试:

``` bash
wget http://SERVER_IP:12121
```

这里的 `SERVER_IP` 是运行 netcat 服务的机器的 IP/域名.

在正常情况下，netcat 在收到一次 wget 发出的 POST 请求之后，会返回 HTTP 200 信息，同时退出，并且执行
后面的 `echo "OK"` 命令.

#### 在 gitlab 上配置

下一步配置 Gitlab Project 和 netcat server 的连接:

在 Gitlab 页面的 Project -> Setting -> Integrations 添加 Webhooks 配置.

在 URL 框中填入刚才我们测试成功的 URL: http://SERVER\_IP:12121

这里的 Trigger 可以选择 Push events, Tag push events 等.

选择完之后点击 Add webhook 按钮来添加，然后可以使用当前页面上的 "Test" 功能来进行测试.

#### netcat systemd service

由于 netcat 在接收到一次 get 请求之后会退出，因此需要一个 systemd service 来让 nc 在退出之后自动重启.

添加 systemd service 文件:

```bash
sudo vim /etc/systemd/system/nchook.service
```

```sh
[Unit]
Description=Gitlab Webhook With Netcat
After=network.target

[Service]
User=YOURUSERNAME
Type=simple
ExecStart=/bin/bash -xc 'echo -e "HTTP/1.1 200 OK\r\n" | nc -q 1 -l -p 12121; bash /home/user/hook.sh'
Restart=always
StartLimitInterval=30s
StartLimitBurst=2

[Install]
WantedBy=multi-user.target
```

为了被调用频率过快，这里使用 `StartLimitInterval=30s` 和 `StartLimitBurst=2` 来限制服务重启频率，表示 30s 
内最多能被重启 2 次.

然后执行

```sh
sudo systemctl start nchook
sudo systemctl enable nchook
```

这里的 `/home/user/hook.sh` 里面就是我们需要完成部署的脚本.

### 使用 SSL

netcat 不支持 HTTPS 协议的监听，为了使用 HTTPS, 可以使用另一个工具: nmap 工具包中的 ncat 工具.
在这里，可以使用 letsencrypt 提供的 SSL 证书

```sh
echo -e "HTTP/1.1 200 OK\r\n" | ncat -l -p 12122 --ssl \
--ssl-cert /home/user/.acme.sh/test.domain.com/fullchain.cer \
--ssl-key /home/user/.acme.sh/test.domain.com/test.domain.com.key ; echo "OK"
```

对于使用 ncat 监听 ssl 请求，可以参考 netcat 的方式，写一个相同的 systemd service 来实现。

然后在 gitlab 中配置 enable ssl.

### ref

[http://www.secist.com/archives/182.html](http://www.secist.com/archives/182.html)   
[https://www.muzilong.cn/article/125](https://www.muzilong.cn/article/125)

