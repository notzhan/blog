---
title: "使用 github issue 系统作为个人博客暨本博客源码分享"
date: 2024-12-12 11:38:28
toc: yes
comment: true
---

# 使用 github issue 系统作为个人博客暨本博客源码分享
## TLDR： 仓库 <https://github.com/notzhan/blog>

## Why

本 blog 旧的构建流程为 编写 Markdown 文件 - 使用 Bash 和 Pandoc 生成静态 HTML - 用 Caddy 发布静态页面，处理 TLS 等

### 旧流程的优势:

- 静态文件存储在本地，容量无限制

- 实时修改、发布

### 旧流程的缺陷 （新方案解决的问题）

- 使用 443 端口发布博客，需要有可以有公网 443 端口的云服务器作转发, 如果该服务器故障，则博客无法访问

- 本地服务器也可能关机、重启、维护等，会导致博客无法访问

- 使用 vim 等编辑本地 markdown、调用 bash 脚本，依赖电脑环境，无法方便使用手机编辑、修改博客内容

### 新方案的优势

- 所有除外部图片链接的数据保存在 github，并且使用 github page 发布

- 可以使用 Github 手机 APP 编辑 markdown、issue

- 无需使用 shell 环境构建静态页面

- 使用简单，如无特别的自定义样式、发布静态页面的需求，只需要使用一个文件即可 (.github/workflows/issue_to_readme.yaml)，发布博客只需要创建 issue 即可

- github issue 本身支持图片上传、markdown 预览、评论、以及链接到其他 issue 等功能

## 使用步骤

1. Fork 本仓库，或者 [下载](https://github.com/notzhan/blog/archive/refs/heads/main.zip)，上传到你的仓库

2. 删除 `post_issues` 和 `post_sources` 中的所有文件, 并且 **务必修改 about.md 文件**，这里是我的信息

> PS: 如果只需要使用 github 仓库作为博客系统，不需要静态页面托管、自定义 css 等，可以删除本项目除 `.github/workflows/issue_to_readme.yaml`  和  **LICENSE** 文件外的所有文件, 即使用 issues 系统作为博客，仅需这一个 action 文件即可。

3. 在 [这里](https://github.com/settings/tokens) 申请 API token，设置 token 的有效期、权限等，只需要配置针对博客仓库的 issue 读权限、commit、push 权限即可，建议使用 Fine-grained token，可以细粒度的控制 token 权限

4. Setting - Code and automation - Action - General - Workflow permissions - Read and write permissions, 如图

![](https://files.imtxc.com/blogfiles/github-action-permissions.png)

5. Setting - Code and automation - Pages - Build and deployment - Source - Github Actions，如图

![](https://files.imtxc.com/blogfiles/github-pages-setting.png)

6. 在博客仓库的 `settings - secrets - actions` 中，创建一个名为 **G_T** 的 secret，值为上一步申请的 token

7. 在第四步同样的位置，创建两个 variables, 名称分别为 `BASE_URL` 和 `BLOG_TITLE`, 值为需要生成的 README.md 中的 H1 内容，
比如 "[XXX BLOG](https://xxxx.github.io/blog)"

8. 完成，在你的博客仓库中，创建一个 issue，issue 标题为博客文章标题，内容为文章正文，创建 issue 之后，会自动生成 `post_issues` 下的 markdown 文件，同时更新仓库的 `README.md` 文件作为博客索引

### 静态页面生成

如果还需要使用本项目生成静态 html 页面，定制 css 等，可以按照需要修改本仓库中 static, css, pandoc 目录中的所有样式、模板
、图标等文件。

### 自定义域名
1. 在博客仓库的 `Setting` - `Page` - `Custom domain` 中，填入你的域名，如 `www.yourblogdomain.com`

2. 在你的 DNS 服务商配置中，增加一个 CNAME，名称为 `www.yourblogdomain.com`, 值为 `yourgithubusername.github.io`, 切记，
这里唯一需要修改的是你的 github 用户名和域名，不要在 `yourgithubusername.github.io` 后加任何仓库名称等内容.

3. 访问  `yourgithubusername.github.io`
