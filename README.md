```
████████╗ █████╗ ███████╗██╗   ██╗██████╗
╚══██╔══╝██╔══██╗██╔════╝██║   ██║██╔══██╗
   ██║   ███████║███████╗██║   ██║██████╔╝
   ██║   ██╔══██║╚════██║██║   ██║██╔═══╝
   ██║   ██║  ██║███████║╚██████╔╝██║
   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝
```

GitHub Projects V2とJiraの統合を管理するためのClaude Code設定リポジトリです。GitHub CLIコマンドとAtlassian MCP Serverを使用して、IssueやJiraチケットのステータスを自動的に更新するワークフローを提供します。

## Features

### GitHub Integration
- **自動ステータス更新**: GitHub IssueのステータスをGitHub Projects V2で自動的に更新
- **複数プロジェクト対応**: Issueが複数のプロジェクトに紐づいている場合、すべてのプロジェクトのステータスを一括更新
- **GraphQL API活用**: GitHub Projects V2のフルパワーを活用した高度な統合

### Jira Integration
- **Atlassian MCP連携**: Atlassian MCP Serverを使用したJiraチケットのステータス自動更新
- **ワークフロー遷移**: Jiraのワークフローに沿った自動ステータス遷移 (TODO→進行中→完了)
- **ブランチ作成時の自動更新**: ブランチ作成と同時にJiraチケットのステータスを自動更新

### Common
- **Claude Code統合**: カスタムスラッシュコマンドとスキルによる効率的なワークフロー

## Prerequisites

### GitHub Integration
- [GitHub CLI](https://cli.github.com/) (gh) がインストールされていること
- GitHub CLIが認証済みであること (`gh auth status` で確認)
- `project` 権限を持つトークンが設定されていること
- Tasup organizationへのアクセス権限

### Jira Integration
- [Atlassian MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/atlassian) が設定されていること
- `.mcp.json` でAtlassian MCP Serverが設定されていること
- Jiraへの認証が完了していること
- 対象チケットへのアクセス権限

## Setup

### このリポジトリのクローン

```bash
git clone https://github.com/Tasup/Tasup.git
cd Tasup
```

### GitHub CLI認証

```bash
# GitHub CLIで認証（project権限を含める）
gh auth login

# 認証状態の確認
gh auth status
```

### Atlassian MCP Server設定

`.mcp.json` でAtlassian MCP Serverを設定：

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-atlassian"
      ]
    }
  }
}
```

初回起動時にJiraへの認証を行います。

## Usage

### GitHub Integration

#### `/create-issue`

新しいGitHub Issueを作成します。

使用方法:
1. Claude Codeで `/create-issue` を実行
2. Issueのタイトルを入力
3. タスクを1行ずつ入力（複数可）
4. プレビューを確認
5. 承認後、自動的にIssueが作成されます

処理フロー:
1. ユーザーにタイトルとタスクを質問
2. タスクをチェックリスト形式でフォーマット
3. プレビューを表示して確認
4. `gh issue create` コマンドでIssueを作成
5. 作成されたIssue URLを表示
6. 次のステップとして `/implement-issue` の実行を案内

#### `/implement-issue`

GitHub Issueの実装を計画・実行します。

使用方法:
1. Claude Codeで `/implement-issue` を実行
2. GitHub Issue URLを入力
3. 自動的にブランチが作成され、ステータスが更新されます
4. 実装計画を確認
5. 承認後、実装が開始されます

処理フロー:
1. Issue URLから情報を抽出 (owner/repo/number)
2. `gh issue view` でIssue詳細を取得
3. ブランチ名を生成（`{repository_name}-{issue_number}-{implement-content}` 形式、40文字以内）
4. `git checkout -b` で新しいブランチを作成
5. `auto-update-issue-status` スキルでステータスを "In Progress" に更新
6. TodoWriteツールで実装タスクリストを作成
7. ユーザー確認後、実装を実行

#### `auto-update-issue-status`

GitHub Issueのステータスを次の段階へ自動的に更新するスキル (Todo→In Progress→Done)。

特徴:
- 複数プロジェクト対応: Issueが複数のプロジェクトに紐づいている場合、すべてのプロジェクトのステータスを一括更新
- 8ステップの構造化されたプロセス
- 包括的なエラーハンドリング
- 更新前後の検証

#### `update-issue-status`

GitHub Issueのステータスを任意のステータスへ更新するスキル。ユーザーがステータスを選択できます。

特徴:
- 複数プロジェクト対応: Issueが複数のプロジェクトに紐づいている場合、すべてのプロジェクトのステータスを一括更新
- インタラクティブなステータス選択
- 4つ以上のステータスオプションにも対応
- 包括的なエラーハンドリング
- 更新前後の検証

### Jira Integration

#### `auto-update-jira-issue-status`

Jiraチケットのステータスを次の段階へ自動的に更新するスキル (TODO→進行中→完了)。

特徴:
- Atlassian MCP Serverを使用したJira API連携
- Jiraのワークフロー遷移を自動実行
- ブランチ作成時の自動ステータス更新に最適
- 8ステップの構造化されたプロセス
- 包括的なエラーハンドリング
- 更新前後の検証

使用方法:
1. Claude Codeでブランチを作成する際に自動的に実行
2. または明示的にスキルを呼び出し
3. Jiraチケット URLを指定
4. 自動的に次のステータスへ遷移

処理フロー:
1. JiraチケットURLから情報を抽出 (cloudId/issueKey)
2. 現在のステータスを取得
3. 利用可能な遷移を取得
4. 次のステータスへの遷移を実行
5. 更新を検証

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

### Jira Management with Atlassian MCP

```bash
# Jiraチケットの情報を取得
mcp__atlassian__getJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123")

# 利用可能な遷移を取得
mcp__atlassian__getTransitionsForJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123")

# ステータスを遷移
mcp__atlassian__transitionJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123", transition: {id: "11"})
```

## Architecture

### Directory Structure

```
.claude/
├── commands/           # スラッシュコマンド
│   ├── create-issue.md
│   ├── implement-issue.md
│   └── jira/
│       └── implement-issue.md
├── skills/            # カスタムスキル
│   ├── auto-update-issue-status/
│   │   └── SKILL.md
│   ├── auto-update-jira-issue-status/
│   │   └── SKILL.md
│   ├── update-issue-status-from-todo-to-in-progress/
│   │   └── SKILL.md
│   ├── update-parent-issue-status/
│   │   └── SKILL.md
│   └── gh-commands.md
└── settings.local.json # 承認済みコマンド設定
```

### 承認済みコマンド

以下のコマンドは `.claude/settings.local.json` で自動承認されています：

#### GitHub関連
- `Bash(gh:*)` - GitHub CLI操作
- `Skill(update-issue-status-from-todo-to-in-progress)` - 任意ステータス更新スキル
- `Skill(auto-update-issue-status)` - 自動ステータス更新スキル
- `Skill(update-parent-issue-status)` - 親Issueステータス更新スキル

#### Jira関連
- `Skill(auto-update-jira-issue-status)` - Jira自動ステータス更新スキル
- `mcp__atlassian__getJiraIssue` - Jiraチケット取得
- `mcp__atlassian__getTransitionsForJiraIssue` - Jira遷移取得
- `mcp__atlassian__transitionJiraIssue` - Jiraステータス遷移
- `Bash(npx -y mcp-remote https://mcp.atlassian.com/v1/sse)` - Atlassian MCP Remote実行

#### 一般
- `Bash(sed:*)` - テキスト処理
- `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(git checkout:*)` - Git操作
- `Bash(cat:*)` - ファイル内容表示
- `Bash(tree:*)` - ディレクトリ構造表示
- `Bash(chmod:*)` - ファイルパーミッション変更
- `Bash(bash:*)` - シェルスクリプト実行
- `WebFetch(domain:github.com)` - GitHub Webフェッチ
- `WebFetch(domain:code.claude.com)` - Claude Code Webフェッチ

## Integration Details

### GitHub Projects V2 Integration

#### Issueステータス更新のワークフロー

1. プロジェクトIDとフィールドIDを特定
2. Issue URLからowner/repo/numberを抽出
3. プロジェクトアイテムリストからIssue番号に対応するitem IDを検索
4. `gh project item-edit` コマンドでステータスを更新
5. `gh issue view` で更新を検証

#### エラーハンドリング

以下のエラーケースに対応：
- 無効なURL形式
- 存在しないIssue
- プロジェクトに関連付けられていないIssue
- 認証スコープの不足
- ネットワークエラー

### Jira Integration

#### Jiraステータス更新のワークフロー

1. JiraチケットURLから情報を抽出 (cloudId/issueKey)
2. Atlassian MCP Serverを使用して現在のステータスを取得
3. 利用可能な遷移を取得
4. 次のステータスへの遷移を実行
5. 更新を検証

#### エラーハンドリング

以下のエラーケースに対応：
- 無効なURL形式
- 存在しないチケット
- 利用可能な遷移が存在しない
- 認証エラー
- ネットワークエラー

## Contributing

プルリクエストを歓迎します。大きな変更の場合は、まずIssueを開いて変更内容を議論してください。

## Authors

| <img src="https://github.com/nakayama-bird.png?size=40" width="40" height="40"> | <img src="https://github.com/karukan029.png?size=40" width="40" height="40"> | <img src="https://github.com/sontixyou.png?size=40" width="40" height="40"> |
|:---:|:---:|:---:|
| [@nakayama-bird](https://github.com/nakayama-bird) | [@karukan029](https://github.com/karukan029) | [@sontixyou](https://github.com/sontixyou) |

