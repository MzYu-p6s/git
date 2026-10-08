<#
    一键把本仓库推送到 GitHub。

    用法：直接双击 push-to-github.cmd，或在本目录运行：
        powershell -NoProfile -ExecutionPolicy Bypass -File .\push-to-github.ps1

    前置条件：本机必须能访问 github.com。
    若 hosts 文件把 github.com 指到了 127.0.0.1，需要先去掉那些条目或开启代理。
#>

$ErrorActionPreference = 'Stop'

# ---- 改成你自己的 GitHub 用户名（必填）----
$GhUser = 'YOUR_GITHUB_USERNAME'
$RepoName = 'GitDocuments'
$Visibility = 'private'   # private 或 public

# ---- git 路径（本机装在这里）----
$Git = 'D:\Program Files\Git\cmd\git.exe'
if (-not (Test-Path $Git)) { $Git = 'git' }

function Info($m) { Write-Host "  $m" }
function Step($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Fail($m) { Write-Host "`n[失败] $m" -ForegroundColor Red; exit 1 }

Write-Host "=== 推送 $RepoName 到 GitHub ===" -ForegroundColor Green

if ($GhUser -eq 'YOUR_GITHUB_USERNAME') {
    Write-Host "`n请先打开本脚本，把 `$GhUser 改成你的 GitHub 用户名。" -ForegroundColor Yellow
    exit 1
}

# ---- 1. 连通性检查 ----
Step '检查 github.com 连通性'
$code = & curl.exe -sS -o NUL -w '%{http_code}' --max-time 15 https://github.com 2>&1
if ("$code" -ne '200' -and "$code" -ne '301' -and "$code" -ne '302') {
    Write-Host "`n无法访问 github.com（返回：$code）" -ForegroundColor Red
    Info '常见原因：hosts 文件把 github.com / api.github.com 指向了 127.0.0.1。'
    Info '解决方式：以管理员身份编辑 C:\Windows\System32\drivers\etc\hosts，删掉这些 github 条目，'
    Info '          或先开启代理（本机曾配置 127.0.0.1:7897）。改完重新运行本脚本。'
    exit 1
}
Info "连通正常（HTTP $code）"

# ---- 2. 提交身份 ----
Step '检查提交身份'
$name = (& $Git config --local user.name)
$email = (& $Git config --local user.email)
if ($name -eq 'DSH User' -or $email -eq 'dsh@localhost') {
    Write-Host "  当前提交身份是占位值：$name <$email>" -ForegroundColor Yellow
    $newName = Read-Host "  请输入用于提交的 GitHub 用户名或昵称（回车沿用 $GhUser）"
    if ([string]::IsNullOrWhiteSpace($newName)) { $newName = $GhUser }
    $newEmail = Read-Host "  请输入提交邮箱（回车使用 $GhUser@users.noreply.github.com）"
    if ([string]::IsNullOrWhiteSpace($newEmail)) { $newEmail = "$GhUser@users.noreply.github.com" }
    & $Git config --local user.name $newName
    & $Git config --local user.email $newEmail
    Info "已设置：$newName <$newEmail>（仅影响之后的提交）"
} else {
    Info "提交身份：$name <$email>"
}

# ---- 3. 关联远程 ----
Step "关联远程 origin"
$url = "https://github.com/$GhUser/$RepoName.git"
& $Git remote remove origin 2>$null | Out-Null
& $Git remote add origin $url
Info $url

# ---- 4. 推送 ----
Step "推送 main 分支（首次会弹出浏览器要求登录 GitHub）"
Info '如果弹出浏览器/设备码页面，请完成授权，凭据会被安全保存，之后无需重复登录。'
& $Git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Fail @"
推送失败。可能原因：
  1) GitHub 上还没有 $GhUser/$RepoName 这个仓库 —— 请先在网页上新建一个同名空仓库（不要勾选添加 README）。
  2) 认证未完成或被取消 —— 重新运行本脚本再试一次。
  3) 网络仍不通 —— 见上面的连通性说明。
"@
}

# ---- 5. 校验 ----
Step '校验远程内容'
& $Git remote -v
& $Git log --oneline -n 5
$status = & $Git status -sb
Info $status
Write-Host "`n完成：https://github.com/$GhUser/$RepoName" -ForegroundColor Green
