<#
    一键把本仓库推送到 GitHub。

    用法（任选其一）：
      1) 直接双击 push-to-github.cmd
      2) 在本目录运行：
         powershell -NoProfile -ExecutionPolicy Bypass -File .\push-to-github.ps1
      3) 指定用户名 / 仓库名 / 可见性：
         powershell -NoProfile -ExecutionPolicy Bypass -File .\push-to-github.ps1 -GhUser 你的用户名 -RepoName GitDocuments -Visibility private

    脚本流程：检查连通性 -> 确认登录状态 -> 确认提交身份
              -> 创建远端仓库（若不存在）-> 关联 origin -> 推送 -> 校验。
#>

[CmdletBinding()]
param(
    [string]$GhUser,                                   # 留空则用 gh 已登录账号
    [string]$RepoName   = 'GitDocuments',
    [ValidateSet('private', 'public')]
    [string]$Visibility = 'private',
    [string]$GhExe      = 'D:\GitDocuments\.tools\gh\bin\gh.exe'
)

$ErrorActionPreference = 'Stop'

$Git = 'D:\Program Files\Git\cmd\git.exe'
if (-not (Test-Path $Git)) { $Git = 'git' }

function Write-Info { param([string]$m) Write-Host "  $m" }
function Write-Step { param([string]$m) Write-Host "`n==> $m" -ForegroundColor Cyan }
function Stop-WithMessage {
    param([string]$m)
    Write-Host "`n[失败] $m" -ForegroundColor Red
    exit 1
}

Write-Host "=== 推送 $RepoName 到 GitHub ===" -ForegroundColor Green

# ---- 0. 准备 gh ----
if (-not (Test-Path $GhExe)) {
    $found = Get-Command gh -ErrorAction SilentlyContinue
    if ($found) { $GhExe = $found.Source }
    else {
        Stop-WithMessage @"
找不到 GitHub CLI（gh）。
  期望路径：D:\GitDocuments\.tools\gh\bin\gh.exe
  也可先安装：winget install --id GitHub.cli --exact --source winget
"@
    }
}

# ---- 1. 连通性检查 ----
Write-Step '检查 github.com 连通性'
$null = & $Git ls-remote https://github.com/octocat/Hello-World.git HEAD 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n无法访问 github.com。" -ForegroundColor Red
    Write-Info '常见原因：hosts 文件把 github.com / api.github.com 指向了 127.0.0.1。'
    Write-Info '解决方式：以管理员身份编辑 C:\Windows\System32\drivers\etc\hosts，'
    Write-Info '          删掉其中 github 相关条目，或先开启代理（本机曾配置 127.0.0.1:7897）。'
    exit 1
}
Write-Info '连通正常'

# ---- 2. 登录状态 ----
Write-Step '检查 GitHub 登录状态'
& $GhExe auth status 2>&1 | ForEach-Object { Write-Info $_ }
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage @"
尚未登录 GitHub。请先执行下面这条命令完成浏览器授权：

    & "$GhExe" auth login --web --git-protocol https

授权完成后重新运行本脚本即可。
"@
}

if (-not $GhUser) {
    $GhUser = (& $GhExe api user --jq .login 2>$null | Select-Object -First 1)
}
if (-not $GhUser) { Stop-WithMessage '无法获取 GitHub 用户名，请用 -GhUser 参数显式指定。' }
Write-Info "账号：$GhUser"

# ---- 3. 提交身份 ----
Write-Step '检查提交身份'
$name  = & $Git config --local user.name
$email = & $Git config --local user.email
if ($name -eq 'DSH User' -or $email -eq 'dsh@localhost' -or -not $name) {
    Write-Host "  当前提交身份是占位值：$name <$email>" -ForegroundColor Yellow
    $newName  = $GhUser
    $newEmail = "$GhUser@users.noreply.github.com"
    & $Git config --local user.name $newName
    & $Git config --local user.email $newEmail
    Write-Info "已设置为：$newName <$newEmail>（仅影响之后的提交）"
} else {
    Write-Info "提交身份：$name <$email>"
}

# ---- 4. 创建远端仓库（已存在则跳过）----
Write-Step "确认远端仓库 $GhUser/$RepoName"
$exists = & $GhExe repo view "$GhUser/$RepoName" --json name --jq .name 2>$null
if ($LASTEXITCODE -eq 0 -and $exists) {
    Write-Info '仓库已存在，直接推送'
} else {
    Write-Info "仓库不存在，正在创建（$Visibility）..."
    & $GhExe repo create "$GhUser/$RepoName" "--$Visibility" --description '文档版本管理仓库'
    if ($LASTEXITCODE -ne 0) { Stop-WithMessage '创建远端仓库失败。' }
}

# ---- 5. 关联远程并推送 ----
Write-Step '关联远程 origin 并推送'
$url = "https://github.com/$GhUser/$RepoName.git"
& $Git remote remove origin 2>$null | Out-Null
& $Git remote add origin $url
Write-Info $url
& $GhExe auth setup-git 2>$null | Out-Null
& $Git push -u origin main
if ($LASTEXITCODE -ne 0) {
    $hint = @(
        '推送失败，可能原因：',
        '  1) 远端仓库已有提交（例如创建时勾选了 README），需先合并：git pull --rebase origin main',
        '  2) 认证失效：重新执行 gh auth login --web --git-protocol https',
        '  3) 网络不通：见上面的连通性说明。'
    ) -join "`r`n"
    Stop-WithMessage $hint
}

# ---- 6. 校验 ----
Write-Step '校验'
& $Git remote -v
& $Git log --oneline -n 5
Write-Info (& $Git status -sb)
Write-Host "`n完成：https://github.com/$GhUser/$RepoName" -ForegroundColor Green
