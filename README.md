# GitDocuments

本仓库用于存放和版本化管理文档。

## 目录

```
GitDocuments/
├── README.md      # 本文件：仓库说明
└── .gitignore     # 忽略规则
```

## 使用方式

### 日常提交

```powershell
git add .
git commit -m "描述这次修改"
git push
```

### 查看改动

```powershell
git status          # 哪些文件被改动
git diff            # 未暂存的具体改动
git log --oneline   # 提交历史
```

## 说明

- 默认分支为 `main`。
- 换行符已配置为 `core.autocrlf=true`，Windows 下编辑文本文件不会产生整文件差异。
- 仓库中**不应**提交密钥、令牌等敏感信息，相关文件已在 `.gitignore` 中排除。
