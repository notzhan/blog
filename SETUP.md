# Fork Setup Guide

This project uses GitHub Issues as a blogging platform and GitHub Actions to build and deploy a static site via GitHub Pages.

## Quick Start (after forking)

### 1. Run the initialization workflow

Go to **Actions → Initialize Fork → Run workflow** in your forked repository.

This one-time step will:
- Remove the original author's blog posts (`post_source/` and `post_issues/`)
- Reset `README.md` and `about.md` to blank templates
- Clear the original author's analytics and comment scripts
- Reset site headers and footers to generic defaults

### 2. Enable GitHub Pages

Go to **Settings → Pages** and set:
- **Source**: `GitHub Actions`

### 3. Configure repository variables

Go to **Settings → Secrets and variables → Actions → Variables** and set the following.

#### Required

| Variable | Description | Example |
|---|---|---|
| `BLOG_TITLE` | Your blog/site name | `Alice's Blog` |
| `BASE_URL` | Your GitHub Pages URL | `https://alice.github.io/blog` |

#### Optional – Analytics

| Variable | Description | Example |
|---|---|---|
| `GOATCOUNTER_URL` | Your GoatCounter instance URL | `https://stats.example.com` |
| `COUNTERSCALE_SITE_ID` | Your Counterscale site ID | `mysite.com` |
| `COUNTERSCALE_URL` | Your Counterscale server URL | `https://counter.example.com` |

#### Optional – Comments (Utterances)

| Variable | Description | Example |
|---|---|---|
| `UTTERANCES_REPO` | GitHub repo used for comments | `alice/blog-comments` |

To use Utterances, create a **public** repository for comments (e.g. `blog-comments`), install the [Utterances app](https://utteranc.es/) on it, then set this variable.

#### Optional – Footer / Statistics

| Variable | Description | Example |
|---|---|---|
| `SITE_AUTHOR` | Your name shown in the footer | `Alice` |
| `COPYRIGHT_YEAR` | Starting year for copyright notice | `2024` |
| `WEBVISO_URL` | Your Webviso statistics server URL | `https://webviso.example.com` |

### 4. Edit about.md

Open `about.md` in the repository and replace the placeholder with your own information.

### 5. Publish your first post

Create a **GitHub Issue** in your repository. The `Generate README` workflow will run automatically and:
- Convert the issue body into a markdown file in `post_issues/`
- Update `README.md` with the new post link

The `Deploy static content to Pages` workflow then runs and publishes the updated site.

> **Note:** Only issues created by the repository owner are published as blog posts.

## Adding static posts (post_source/)

You can also add handwritten markdown files to `post_source/`. Each file must start with YAML front matter:

```markdown
---
title: "My Post Title"
date: 2024-01-15 10:00:00
toc: yes
comment: true
---
```

Supported front matter keys:

| Key | Description |
|---|---|
| `title` | Post title |
| `date` | Publication date |
| `modify` | Last modified date (used for sorting if present) |
| `toc` | Show table of contents (`yes`/`no`) |
| `comment` | Enable comments (`true`/`false`) |
| `slug` | Custom URL slug for the post |

## How it works

```
GitHub Issue created/edited
        │
        ▼
issue_to_readme.yaml
  • Fetches all issues via GitHub API
  • Generates post_issues/<n>_<title>.md for each issue
  • Commits & pushes updated README.md and post files
        │
        ▼
gen_deploy_static.yml
  • Generates site config files from repository variables
    (header, footer, analytics, comment system)
  • Runs build_site.sh -b (pandoc)
  • Deploys deploy/ to GitHub Pages
```
