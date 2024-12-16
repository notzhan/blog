---
title: "本 blog 构建环境迁移到 Github Action"
date: 2024-12-12 11:32:16
toc: yes
comment: true
---

# 本 blog 构建环境迁移到 Github Action
通过创建、编辑 GitHub Issue 的方式发布博客

- 将 owner 创建的 issue 的正文和 comment 保存到 `post_issues/${issue_number}_${issue_title}.md` 中

- 将 owner 创建的 issues 列表生成为 README.md 作为 index，链接指向 issue html link, 按照年作为 h2 title

- 兼容历史 blog 的 markdown 文档，也加入到 README.md 索引中, 链接指向该 markdown 文件

- 将所有 markdown 文件生成静态 HTML，部署到 github pages
