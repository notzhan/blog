---
title: Win10 Tips
date: 2023-05-17 20:12:21
toc: true
comment: no
---

# Win10 Tips

## Preview Nikon Raw Image

install the `Nikon NEF Codec` from Nikon.

## WebDAV download fails with file size exceeds the limit error

    Error 0x800700DF: The file size exceeds the limit allowed and cannot be saved.


```bash
win+R
regedit

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WebClient\Parameter
```

`FileSizeLimitInBytes` -> `ffffffff`

## Preview file Using Space like Macos
install the `quick look` program.
