---
title: Setting up cgit with caddy2 http.handlers.cgi on Debian
date: 2024-12-02 08:10:00
toc: no
slud: setting-up-cgit-with-caddy2
comment: true
---

# Deploy Cgit with Caddy on Debian

## Git repository server

### Create User on host
```bash
sudo mkdir -p /tank/git/repos/
sudo useradd -c "Git Backend User" -d /tank/git/repos -m -s /usr/bin/git-shell git
sudo chown -R git:git /tank/git
```

### scripts

```bash
# /tank/git/repos/git-shell-commands/ls
#!/usr/bin/env sh

source "$(dirname "$0")/pre-script"

for repo in $(/usr/bin/find -maxdepth 2 -type d -name "*.git"); do echo $repo | cut -c3- | rev | cut -c5- | rev; done | sort
```

## Install and config cgit

```bash
apt install git cgit
```

### /etc/cgitrc
```conf
virtual-root=/
css=/cgit-css/cgit.css
logo=/cgit-css/cgit.png
# Specify some default clone urls using macro expansion
clone-url=https://git.site.com/$CGIT_REPO_URL git@git.site.com:$CGIT_REPO_URL
# Show owner on index page
enable-index-owner=0
# Source gitweb.description, gitweb.owner from each project config
enable-git-config=1
# Allow http transport git clone
enable-http-clone=1
# Show extra links for each repository on the index page
enable-index-links=1
# Enable ASCII art commit history graph on the log pages
enable-commit-graph=1
# Show number of affected files per commit on the log pages
enable-log-filecount=1
# Show number of added/removed lines per commit on the log pages
enable-log-linecount=1
# Sort branches by date
branch-sort=age
# Allow download of tar.gz, tar.bz2 and zip-files
snapshots=tar.bz2 zip
## List of common mimetypes
mimetype.gif=image/gif
mimetype.html=text/html
mimetype.jpg=image/jpeg
mimetype.jpeg=image/jpeg
mimetype.pdf=application/pdf
mimetype.png=image/png
mimetype.svg=image/svg+xml
mimetype.js=text/javascript
mimetype.css=text/css
mimetype.pl=text/x-script.perl
mimetype.pm=text/x-script.perl-module
mimetype.py=text/x-script.python

# Highlight source code with python pygments-based highligher
source-filter=/usr/lib/cgit/filters/syntax-highlighting.py

# Format markdown, restructuredtext, manpages, text files, and html files
# through the right converters
about-filter=/usr/lib/cgit/filters/about-formatting.sh

readme=:README.md
readme=:README
readme=:README.html
readme=:README.txt

root-title=Repositories
root-desc=Your's Git Repositories

scan-path=/path/to/git/repos
```

## config caddy

download caddy from <https://caddyserver.com/download> with [http.handlers.cgi](https://caddyserver.com/docs/modules/http.handlers.cgi)

config caddy:

```yaml
{
        order cgi before respond
        ...

}
git.site.com {
        handle_path /cgit-css/* {
                root * /usr/share/cgit/
                file_server
        }
        handle {
                cgi * /usr/lib/cgit/cgit.cgi
        }
}
```

## ref

<https://www.sixfoisneuf.fr/posts/setting-up-cgit-with-caddy2/>

<https://luke.hsiao.dev/blog/cgit-caddy-gitolite/>
