---
title: Create Debian package from souce
date: 2017-06-28 22:15:10
toc: true
---

### 1. Install build tools

```bash
sudo apt-get install devscripts dh-make
```

### 2. Prepare source code

```bash
mkdir -p ~/tmp/testdeb/debian && cd ~/tmp/testdeb
touch testhello.c Makefile
touch debian/{changelog,compat,control,rules}
echo 9 > debian/compat
```

`testhello.c`

``` C
#include <stdio.h>

int main (int argc, char *argv[])
{
	printf("Hello\n");

	return 0;
}

```

`Makefile`

``` Makefile
OBJS = testhello.o

CC = gcc -g

all:$(OBJS)
	$(CC) -o testhello $(OBJS)

clean:
	rm -f *.o testhello

.PHONY:all clean
```

`debian/changelog`
```
testhello (1.0-1) unstable; urgency=medium

  * init

 -- xxx <xx@xxx.com>  Mon, 26 Jun 2017 17:25:36 +0800
```

`debian/control`
```
Source: testhello
Priority: optional
Maintainer: xxx <xx@xxx.com>
Build-Depends: debhelper (>=9)
Standards-Version: 3.9.6

Package: testhello
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: testhello
```

`debian/rules`
``` Makefile
#!/usr/bin/make -f  
%:  
	dh $@
```

#### Final directory tree
```
./testhello.c
./debian
./debian/compat
./debian/changelog
./debian/control
./debian/rules
./Makefile
```

### 3. Build

``` bash
debuild -us -uc -b
```

### ref:
[HOWTO: Build debian packages for simple shell scripts](https://blog.packagecloud.io/eng/2016/12/15/howto-build-debian-package-containing-simple-shell-scripts/)

[HowToPackageForDebian](https://wiki.debian.org/HowToPackageForDebian)
