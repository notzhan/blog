---
title: Org-mode 转到 HTML 不要转义 `_`
date: 2018-08-30 12:25:11
slug: emacs-orgmode-subscripts
---

在使用 Orgmode 记笔记的过程中，可能在链接或者文本中用到 `_` 字符, 在转到 HTML 格式的时候，会被
显示成下标的形式，可以用以下方法解决:

- 使用转义符 `\_` 代替 `_`, 如果笔记中只有个别的 `_` 符号，可以用这个方式  
- 在 Org 文件中添加设置 `#+OPTIONS: ^:nil` 或者 `#+OPTIONS: ^:{}`, 这样在输出到 HTML 文件时，
就不会把 Org 文件中的 `_` 转换成下标格式.

### ref:
[Subscripts and superscripts](https://orgmode.org/manual/Subscripts-and-superscripts.html)

