# GitDocuments

本仓库用于存放和版本化管理文档。

## 目录

```
GitDocuments/
├── README.md             # 本文件：仓库说明
├── .gitignore            # 忽略规则
├── push-to-github.ps1    # 一键推送到 GitHub（改好用户名后运行）
└── push-to-github.cmd    # 上面脚本的双击入口
```

## 日常使用

### 提交改动

```powershell
git add .
git commit -m "描述这次修改"
git push
```

### 查看状态

```powershell
git status          # 哪些文件被改动
git diff            # 未暂存的具体改动
git log --oneline   # 提交历史
```

## 推送到 GitHub

1. 先在 GitHub 网页上新建一个**空仓库**，名字 `GitDocuments`（不要勾选添加 README）。
2. 打开 `push-to-github.ps1`，把顶部的 `YOUR_GITHUB_USERNAME` 改成你的 GitHub 用户名
   （如需公开仓库，把 `$Visibility` 改为 `public`）。
3. 双击 `push-to-github.cmd`，按提示完成一次浏览器登录授权即可。

> 注意：本机 `hosts` 文件目前把 `github.com`、`api.github.com` 等域名指向了 `127.0.0.1`，
> 在去掉这些条目或开启代理之前，任何推送都会失败。详见下方「已知环境问题」。

## 已知环境问题

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 访问 github.com 失败、TLS 报错 | `hosts` 把 github.com 及 `*.githubusercontent.com` 指向 `127.0.0.1` | 以管理员身份编辑 `C:\Windows\System32\drivers\etc\hosts` 删除这些条目，或开启代理（本机曾配置 `127.0.0.1:7897`） |
| `winget` 安装失败，退出码异常 | msstore 源的交互式协议提示无法在非交互环境应答 | 加 `--source winget` 重试，或改用官方 zip 免安装版 |
| 首次 `git push` 无法认证 | 系统未安装 GitHub CLI，也无 SSH 密钥 | 已配置 Git Credential Manager（GCM），推送时会自动走浏览器授权 |

## 说明

- 默认分支为 `main`。
- 换行符已配置为 `core.autocrlf=true`，Windows 下编辑文本文件不会产生整文件差异。
- 仓库中**不应**提交密钥、令牌等敏感信息，相关文件已在 `.gitignore` 中排除。
- 当前首次提交使用的身份是占位值 `DSH User <dsh@localhost>`；运行推送脚本时会被替换为你的真实身份（只影响之后的提交）。
