---
title: 签名 Linux Kernel 的内核模块
date: 2018-08-29 17:20:18
slug: linux-kernel-signing
---

### 起因

由于在编译 kernel 的 rpm package 时，在 kernel config 中打开了 "Module signature verification" 和 "Automatically sign all modules" 选项,
因此编译完的 kernel 中开启了模块签名验证, 同时编译的内和模块也自动签名了。
然后在编译另一个独立的内核模块的过程中，遇到了

> module verification failed: signature and/or required key missing - tainting kernel

这样的 dmesg warning, 因此需要把单独编译的 kernel module 也使用和 kernel 相同的 key 来签名，来解决遇到的问题。

### Kernel 中的 module sign 配置

打开 Automatically sign all modules, 所以在 make modules\_install 时，会对 kernel 中的模块进行自动签名.

### 对单独的 module 进行签名.

- 使用 kernel 源码目录中的 scripts/sign-file 进行签名
``` bash
./scripts/sign-file sha1 signing_key.pem signing_key.x509 xxx.ko
```
- 检查模块是否被签名
``` bash
xxd xxx.ko |tail
```
- 移除签名
``` bash
strip --strip-debug xxx.ko
```

### 使用自己的 key 进行签名
kernel 默认会使用自动生成的 key 对 modules 进行前面，如果要使用固定的 key，可以自己使用 openssl 来生成.

``` bash
openssl req -new -nodes -utf8 -sha256 -days 36500 -batch -x509 \
   -config x509.genkey -outform DER -out signing_key.x509 \
   -keyout signing_key.pem
```

这样会生成 `signing_key.x509` 和 `signing_key.pem` 这两个文件.

x509.genkey 内容:
```yaml
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
x509_extensions = myexts

[ req_distinguished_name ]
CN = Build my kernel key

[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
```

### ref
[https://www.kernel.org/doc/html/v4.17/admin-guide/module-signing.html](https://www.kernel.org/doc/html/v4.17/admin-guide/module-signing.html)   
[https://wiki.gentoo.org/wiki/Signed\_kernel_module_support](https://wiki.gentoo.org/wiki/Signed_kernel_module_support)   
[https://ihexon.github.io/develop/Signed-kernel-module-support/](https://ihexon.github.io/develop/Signed-kernel-module-support/)
