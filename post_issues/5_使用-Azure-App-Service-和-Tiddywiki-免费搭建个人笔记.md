---
title: "使用 Azure App Service 和 Tiddywiki 免费搭建个人笔记"
date: 2025-01-23 02:45:18
toc: yes
comment: true
---

# 使用 Azure App Service 和 Tiddywiki 免费搭建个人笔记
# 使用 Azure App Service 和 Tiddywiki 免费搭建个人笔记

## 依赖

- Azure 账号(个人账号、开发者订阅等均可)，免费，需要验证信用卡

## 限制

- 免费的 Azure App Service 有 CPU 时间、内存等使用限制，可能影响到使用的限制为每天 165MB 出站流量

![quota1](https://files.imtxc.com/blogfiles/azure-tiddlywiki/quota1.png)

- 不能使用自定义域名，只能使用 `*.azurewebsites.net`


## 部署步骤

### Azure 创建 app，配置 ftps

1. 创建一个新的 Web App 和资源组
    - 设置唯一的实例名称，该名称将会是笔记的访问地址，例如名称为 `test-tiddywiki`, 则访问地址为: `https://test-tiddywiki.azurewebsites.net`

    - 发布选择 “代码”

    - 运行时堆栈选择 “Node 20 LTS”

    - 操作系统选择 “Linux”

    - 区域选择就近区域

![createapp1](https://files.imtxc.com/blogfiles/azure-tiddlywiki/createapp1.png)

    - 定价区域选择 ** 免费(F1) **

![createapp2](https://files.imtxc.com/blogfiles/azure-tiddlywiki/createapp2.png)

2. 创建完成后，进入 Web App 的配置页面，找到 “设置 - 配置”, 打开 "SCM 基本身份验证" 和 "FTP 基本身份验证发布凭据"

![ftps1](https://files.imtxc.com/blogfiles/azure-tiddlywiki/createapp3.png)


3. 在 "部署 - 部署中心" 中找到 "FTPS" 选项，获取 FTPS 主机名, 设置用户名和密码

![ftps2](https://files.imtxc.com/blogfiles/azure-tiddlywiki/createapp4.png)

### 下载 Tiddywiki, 修改 package.json, 上传到 Azure

```bash
git clone https://github.com/TiddlyWiki/TiddlyWiki5.git
cd TiddlyWiki5
mkdir -p wiki/tiddlers
cp ./editions/empty/tiddlywiki.info wiki/

```

修改 `package.json` 中的 `scripts` 为如下内容

```json
  "scripts": {
    "start": "node tiddlywiki.js ./wiki --listen port=8080 host=0.0.0.0 username=httpusername password=httppassword"
  }
```
![package.json](https://files.imtxc.com/blogfiles/azure-tiddlywiki/packagejson.png)


```bash
zip -r tiddywiki.zip .

## lftp 用户名和密码为刚才在 azure 创建的 ftps 用户名和密码
lftp -u "ftpusername" ftps://xxxxxxxxx

put tiddywiki.zip

```
### 在 azure 中通过 ssh 解压 tiddywiki.zip

- 在 azure 中，刚才创建的 app 中, 找到 "开发工具 - SSH", 点击 "转到", 会打开 web ssh 终端

```bash
cd /home/site/wwwroot
unzip -q tiddywiki.zip
```

- 解压完成后关闭 web ssh 终端

- 在 web app 管理页面中，找到 "概述 - 重启"，点击重启

![deploy](https://files.imtxc.com/blogfiles/azure-tiddlywiki/deploy.png)

### 访问 Tiddywiki

发布完成后，等待几分钟，访问 `https://your-appname.azurewebsites.net` 即可看到 Tiddywiki 的界面, 需要使用 httpuser 和 httppassword 认证
