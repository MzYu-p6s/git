# GitDocuments

本仓库用于存放和版本化管理文档。

- 远端仓库：<https://github.com/MzYu-p6s/git>
- 默认分支：`main`
- 当前状态：已初始化并完成首次推送（3 次提交）

## 目录

```
GitDocuments/
├── README.md             # 本文件：仓库说明
├── .gitignore            # 忽略规则
├── push-to-github.ps1    # 一键推送到 GitHub（自动识别账号、自动建仓库）
└── push-to-github.cmd    # 上面脚本的双击入口
```

## 日常使用

### 提交并推送改动

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
git remote -v       # 远端地址
```

## 关于推送脚本

`push-to-github.ps1` 会依次：检查连通性 → 检查登录状态 → 确认提交身份 → 创建远端仓库（若不存在）→ 关联 `origin` → 推送 → 校验。

它依赖 **GitHub CLI（gh）**，本机目前**没有安装**，因此脚本暂时不可用；日常推送直接用 `git push` 即可。

需要时安装 gh：

```powershell
winget install --id GitHub.cli --exact --source winget
```

（注意：`winget` 的 `msstore` 源会弹出交互式协议确认，在非交互环境下会失败，所以要显式加 `--source winget`。）

## 认证说明

- 本机**没有**持久保存 GitHub 凭据。推送时会由 Git Credential Manager（GCM）触发一次浏览器授权；
  授权成功后凭据会存入 Windows 凭据管理器，之后 `git push` 无需重复登录。
- 若需要在无法弹出浏览器的环境登录，可使用 GitHub 设备码流程：打开 <https://github.com/login/device>，
  输入终端给出的代码并授权即可。
- 仓库中**不应**提交密钥、令牌等敏感信息，相关文件已在 `.gitignore` 中排除。

## 本机环境注意事项

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| PowerShell 5.1 执行含中文的 `.ps1` 报语法错误 | 5.1 会按 ANSI 读取无 BOM 的 UTF-8 脚本 | 用带 BOM 的 UTF-8 保存脚本 |
| `curl.exe` 访问 HTTPS 报 `CRYPT_E_NO_REVOCATION_CHECK` / `SEC_E_NO_CREDENTIALS` | 系统 curl 走 schannel，证书吊销检查在本机不可用 | 改用 `Invoke-RestMethod`，或 `curl --ssl-no-revoke` |
| `git fetch`/`ls-remote` 偶发 `SEC_E_NO_CREDENTIALS` | 同一 schannel 问题间歇出现 | 稍后重试；`git push` 通常不受影响 |
| 访问 github.com 偶发失败 | `hosts` 文件中存在把 `github.com`、`api.github.com`、`*.githubusercontent.com` 指向 `127.0.0.1` 的条目 | 以管理员身份编辑 `C:\Windows\System32\drivers\etc\hosts` 删除这些条目，或开启代理（本机曾配置 `127.0.0.1:7897`） |

## 说明

- 换行符已配置为 `core.autocrlf=true`，Windows 下编辑文本文件不会产生整文件差异。
- 首次提交（`c72854e`）的提交身份是占位值 `DSH User <dsh@localhost>`；
  运行推送脚本时会被替换为真实身份（仅影响之后的提交）。
