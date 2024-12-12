---
title: Using Mutt Msmtp and Offlineimap
date: 2012-04-22 11:18:00
updated: 2017-06-25
---

## 1. Offlineimap

安装 Offlineimap, 使用 offlineimap 可以把 gmail imap 目录中的邮件同步到本地目录, 方便离线查看邮件.

``` bash
sudo apt-get install offlineimap
```

编辑配置文件: `vim ~/.offlineimaprc`:

```bash
ui = ttyui
accounts = GMail

[Account GMail]
localrepository = Gmail-Local
remoterepository = Gmail-Remote

[Repository Gmail-Local]
type = Maildir
localfolders = ~/Mails/Gmail

[Repository Gmail-Remote]
type = Gmail 
keepalive = 30
realdelete = yes
holdconnectionopen = yes
remoteuser = txc.yang@gmail.com
remotepass = xxxxx
remotepassfile = ~/.mutt/passwd

#"[Gmail]/Some Folder" --> some_folder
nametrans = lambda folder: re.sub('^inbox$', 'INBOX',
						   re.sub(' +', '_',
						   re.sub(r'.*/(.*)$', r'\1', folder).lower()))

# vim: ft=cfg tw=0
```

这里, 我的邮箱目录是 `~/Mails/Gmail`, 配置完成之后, 使用``offlineimap -o`` 来同步邮件.
我设置每隔 10 分钟同步一次邮箱, 使用了这样一个同步邮件的脚本:

```bash
#!/bin/bash
PID=$(pgrep offlineimap)
[[ -n "$PID" ]] && kill $PID
offlineimap -o -u quiet &>/dev/null &
exit 0
```

将上面这个脚本保存为 `syncmail.sh` 并赋予可执行权限,放到 `/usr/local/bin` 下面

```bash
sudo chmod +x syncmail.sh
sudo cp syncmail.sh /usr/local/bin/
```

然后 `crontab -e`, 在后面添加: 

```bash
*/10 * * * * /usr/local/bin/syncmail.sh
```

这样, 每隔10分钟, 系统会同步一次我的邮箱.

## 2. Msmtp
用来发送邮件的软件是 Msmtp, 安装 ``sudo apt-get install msmtp``, 然后同样是编辑配置文件: ``~/.msmtprc``,
这里的配置比较简单,添加下面的内容就可以:

```bash
defaults
logfile /tmp/msmtp.log

# gmail account
account gmail
auth on
host smtp.gmail.com
port 587
user txc.yang
password xxxxx
from txc.yang@gmail.com
tls on

#tls_trust_file /etc/ssl/certs/ca-certificates.crt
# set default account to use (from above)
account default : gmail
```

## 3. Mutt

安装 mutt

```bash
sudo apt-get install mutt
```
配置文件是 `~/.muttrc`
添加如下内容:

```bash
# options
set mbox_type   = Maildir           
set folder      = ~/Mails/Gmail    
set spoolfile   = "+INBOX"        
set mbox        = "+archive"     
set postponed   = "+drafts"     
set editor="vim"
set include=yes
set indent_str="> "
set from='Imtxc <txc.yang@gmail.com>'
set use_from=yes
set envelope_from=yes 
set realname='Imtxc'
set reverse_name=yes
set reverse_realname=yes

unset record                   

set sendmail    = /usr/bin/msmtp 

# mailboxes
mailboxes +INBOX +archive +sent +drafts +spam +trash

```

这样,就完成了最基本的 Mutt + msmtp + offlineimap 配置,可以用来收发邮件, 完整配置可以参考我的[配置文件](https://github.com/imtxc/dotfiles/blob/master/.muttrc).

参考资料:

[Mutt + Gmail + Offlineimap](http://pbrisbin.com/posts/mutt_gmail_offlineimap)

[offlineimap](http://offlineimap.org)
