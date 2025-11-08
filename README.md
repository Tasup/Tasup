# Tasup

GitHub Projects V2とGitHub Issuesの統合を管理するためのClaude Code設定リポジトリです。GitHub CLIコマンドを使用して、Issueのステータスを自動的に更新するワークフローを提供します。

## Features

- **自動ステータス更新**: GitHub IssueのステータスをGitHub Projects V2で自動的に更新
- **Claude Code統合**: カスタムスラッシュコマンドとスキルによる効率的なワークフロー
- **GraphQL API活用**: GitHub Projects V2のフルパワーを活用した高度な統合

## Prerequisites

以下の環境が必要です：

- [GitHub CLI](https://cli.github.com/) (gh) がインストールされていること
- GitHub CLIが認証済みであること (`gh auth status` で確認)
- `project` 権限を持つトークンが設定されていること
- Tasup organizationへのアクセス権限

## Setup

### GitHub CLI認証

```bash
# GitHub CLIで認証（project権限を含める）
gh auth login

# 認証状態の確認
gh auth status
```

### このリポジトリのクローン

```bash
git clone https://github.com/Tasup/Tasup.git
cd Tasup
```

## Usage

### スラッシュコマンド

#### `/issue-progress`

GitHub IssueのステータスをGitHub Projects V2で「In progress」に更新します。

使用方法:
1. Claude Codeで `/issue-progress` を実行
2. Issue URLを入力
3. 自動的にステータスが「In progress」に更新されます

処理フロー:
1. Issue URLから情報を抽出 (owner/repo/number)
2. GraphQL APIでプロジェクト情報を取得
3. 現在のステータスを確認
4. 既に「In progress」の場合はスキップ
5. ステータスを更新
6. 更新結果を検証

### スキル

#### `update-issue-status-from-todo-to-in-progress`

GitHub IssueのステータスをTODOからIN_PROGRESSに更新するスキル。

特徴:
- 7ステップの構造化されたプロセス
- 包括的なエラーハンドリング
- 更新前後の検証

## Common Commands

### GitHub Projects Management

```bash
# プロジェクト一覧を表示
gh project list --owner Tasup --format json

# プロジェクト内のアイテム一覧
gh project item-list PROJECT_NUMBER --owner Tasup --format json --limit 100

# プロジェクトのフィールド一覧
gh project field-list PROJECT_NUMBER --owner Tasup --format json

# IssueステータスをProjectで更新
gh project item-edit --id ITEM_ID --project-id PROJECT_ID --field-id FIELD_ID --single-select-option-id OPTION_ID

# Issue情報をプロジェクト情報と共に表示
gh issue view ISSUE_NUMBER --json projectItems
```

## Architecture

### Directory Structure

```
.claude/
├── commands/           # スラッシュコマンド
│   └── issue-progress.md
├── skills/            # カスタムスキル
│   └── update-issue-status-from-todo-to-in-progress/
│       └── SKILL.md
└── settings.local.json # 承認済みコマンド設定
```

### 承認済みコマンド

以下のコマンドは `.claude/settings.local.json` で自動承認されています：

- `Bash(sed:*)` - テキスト処理
- `Bash(gh:*)` - GitHub CLI操作
- `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(git push:*)` - Git操作
- `Skill(update-issue-status-from-todo-to-in-progress)` - Issue更新スキル
- `Bash(tree:*)` - ディレクトリ構造表示

## GitHub Projects V2 Integration

### Issueステータス更新のワークフロー

1. プロジェクトIDとフィールドIDを特定
2. Issue URLからowner/repo/numberを抽出
3. プロジェクトアイテムリストからIssue番号に対応するitem IDを検索
4. `gh project item-edit` コマンドでステータスを更新
5. `gh issue view` で更新を検証

### エラーハンドリング

以下のエラーケースに対応：
- 無効なURL形式
- 存在しないIssue
- プロジェクトに関連付けられていないIssue
- 認証スコープの不足
- ネットワークエラー

## Contributing

プルリクエストを歓迎します。大きな変更の場合は、まずIssueを開いて変更内容を議論してください。

