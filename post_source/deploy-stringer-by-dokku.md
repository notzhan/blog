---
title: 使用 Dokku 部署 Web/Fever RSS 阅读器
date: 2017-07-06 20:10:10
slug: deply-stringer-by-dokku
---

<style>
.info {
    padding: 10px;
    color: #9F6000;
    background-color: #FEEFB3;
}
</style>

::::: info
2022-05 update: rss 阅读器已经迁移到 `miniflux`
:::::

### 关于 [Stringer][stringerid]

> A self-hosted, anti-social RSS reader.
  Stringer has no external dependencies, no social recommendations/sharing, and no fancy machine learning algorithms.
  But it does have keyboard shortcuts and was made with love!

在 VPS 主机上面自己搭建 RSS 阅读器, 可以避免由于网络故障导致无法连接一些公开服务或者有些服务关闭导致需要频繁的寻找新的工具的问题.

Stringer 是一个开源的 RSS 阅读器, 我使用 Dokku 搭建在 VPS 上面, 可以同时支持 Web
访问和其他支持 Fever 协议的手机 RSS 客户端.


### 在安装好 dokku 的 Server 上创建 App

``` bash
dokku apps:create rss
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
dokku postgres:create rss-database
dokku postgres:link rss-database rss
```
在 link postgres 的过程中, 会打印出 `url: postgres://postgres:xxx/rss_database` 
这句配置, 需要记录下来.

### 在本地电脑中 clone stringer 并且配置

``` bash
git clone git://github.com/swanson/stringer.git
cd stringer
```

编辑 `config/database.yml` 文件, 修改其中的 url 为上一步记录的 link, 也可以通过
`dokku config rss` 命令在服务器上查看数据库配置

```sh
production:
adapter: postgresql
url: postgres://postgres:xxxxxxase:5432/rss_database # 修改这句
encoding: unicode
pool: 5
```

### push stringer 到 dokku
```sh
git remote add dokku dokku@xxxx.com:rss # 替换主机名
git push dokku master
```

执行 git push 之后, 可能会提示

```sh
 Command: 'set -o pipefail; curl --fail --retry 3 --retry-delay 1 --connect-timeout \
 3 --max-time 30 https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/ruby-2.0. \
 0-p451-default-cache.tgz -s -o - | tar zxf -' failed unexpectedly:
 !
 !     gzip: stdin: unexpected end of file
 !     tar: Unexpected EOF in archive
 !     tar: Unexpected EOF in archive
 !     tar: Error is not recoverable: exiting now
```
这样的错误, 需要在服务器上执行

``` bash
dokku config:set rss  CURL_TIMEOUT=600

```

然后在本地重新执行

```sh
git push dokku master
```

执行完成之后, 会返回已经可以通过 rss.xxxx.com 来访问这样的提示. 这时还没有配置完成,
因此访问会出现 `500 内部服务器错误`

### 在服务器上配置 stringer

在服务器上执行 

```sh
dokku config:set rss APP_URL="rss.xxxx.com"
dokku config:set rss SECRET_TOKEN=`openssl rand -hex 20`
dokku run rss bundle exec rake db:migrate
dokku ps:restart rss
```

这时, 在浏览器中访问 rss.xxxx.com, 会转到设置密码的页面, 设置完之后, 就可以添加 feed 
来使用了

### 使用 HTTPS

使用 letsencrypt 来开启 https 访问, 在服务器上执行:

```bash
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
dokku config:set --no-restart rss DOKKU_LETSENCRYPT_EMAIL=your@email.tld
dokku letsencrypt rss
dokku letsencrypt:cron-job --add
```

现在访问 http://rss.xxxx.com 会自动跳转到 https://rss.xxxx.com.

### 定时更新 Feeds
添加 Feed 之后, 在 Server 上使用 `dokku --rm run rss bundle exec rake fetch_feeds`
命令来抓取 Rss 源.

可以使用 `crontab` 来定时的同步 RSS 源:

在服务器上执行 `crontab -e`, 在最后添加一行

```sh
@hourly dokku --quiet --rm run rss bundle exec rake fetch_feeds
```

这样设置为每一小时同步一次.

### 手机客户端

Stringer 支持使用 fever 协议的 rss 客户端, 如 `Reeder` 和 `Unread`

下载 RSS App 之后, 对应的服务器, 账户配置如下:

```sh
Server: https://rss.xxx.com/fever
Email: stringer
Password: yourpassword
```

如果提示密码不正确, 在服务器上执行以下命令配置密码:

```bash
dokku run rss bundle exec rake db:migrate
dokku run rss bundle exec rake change_password
```

### ref

[https://github.com/swanson/stringer/blob/master/docs/Heroku.md](https://github.com/swanson/stringer/blob/master/docs/Heroku.md)

[Deploy your Rails applications like a pro with Dokku and DigialOcean](http://www.rubyfleebie.com/how-to-use-dokku-on-digitalocean-and-deploy-rails-applications-like-a-pro)

[Deploying to Dokku](https://github.com/dokku/dokku/blob/master/docs/deployment/application-deployment.md)

[Mini Tutorial for installing huginn on dokku](https://github.com/huginn/huginn/wiki/Mini-Tutorial-for-installing-huginn-on-dokku)

[stringerid]: https://github.com/swanson/stringer
