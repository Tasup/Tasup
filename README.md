# Tasup

GitHub Projects V2とGitHub Issuesの統合を管理するためのClaude Code設定リポジトリです。

任意のorganizationやユーザーのGitHub Projectsで使用できます。

## セットアップ

### 1. GitHub CLIの認証

```bash
gh auth login
```

#### 必要な権限

- 対象organizationまたはユーザーリポジトリへのアクセス権
- 対象リポジトリへのwrite権限
- GitHub Projects V2への書き込み権限

認証時に以下のスコープを選択してください：
- `repo` (full control)
- `project` (full control)
- `read:org`

確認：
```bash
gh auth status
# Token scopes: 'project', 'read:org', 'repo' が含まれていること
```


## 使い方

TBD
