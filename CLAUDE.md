# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tasupは、GitHub Projects V2とJiraの統合を管理するためのClaude Code設定リポジトリ。GitHub CLIコマンドとAtlassian MCP Serverを使用して、Issueやチケットのステータスを自動的に更新するワークフローを提供。

## Common Commands

### GitHub Projects Management

```bash
# List projects for the organization
gh project list --owner Tasup --format json

# List items in a project
gh project item-list PROJECT_NUMBER --owner Tasup --format json --limit 100

# List fields in a project
gh project field-list PROJECT_NUMBER --owner Tasup --format json

# Update issue status in project
gh project item-edit --id ITEM_ID --project-id PROJECT_ID --field-id FIELD_ID --single-select-option-id OPTION_ID

# View issue with project information
gh issue view ISSUE_NUMBER --json projectItems
```

### Git Workflow

```bash
# Standard git operations
git add .
git commit -m "message"
git push
```

## Architecture

### Claude Code Custom Commands & Skills

このリポジトリは以下のClaude Code拡張機能を提供：

#### Slash Command: `/create-issue`

Location: `.claude/commands/create-issue.md`

GitHub Issueを作成するコマンド。以下のプロセスで動作：

1. ユーザーにIssueのタイトルとタスクを質問
2. タスクをチェックリスト形式でフォーマット
3. プレビューを表示してユーザーに確認
4. `gh issue create`コマンドでIssueを作成
5. 作成されたIssue URLを表示し、次のステップとして `/implement-issue` の実行を案内

#### Slash Command: `/implement-issue`

Location: `.claude/commands/implement-issue.md`

GitHub Issueの実装を計画・実行するコマンド。以下のプロセスで動作：

1. Issue URLから情報を抽出
2. `gh issue view`でIssue詳細を取得
3. ブランチ名を生成（`{repository_name}-{issue_number}-{implement-content}`形式、40文字以内）
4. `git checkout -b`で新しいブランチを作成
5. `auto-update-issue-status`スキルを使用してIssueステータスを "In Progress" に更新
6. TodoWriteツールで実装タスクリストを作成
7. ユーザー確認後、実装を実行

#### Skill: `auto-update-issue-status`

Location: `.claude/skills/auto-update-issue-status/SKILL.md`

GitHub Issueのステータスを次の段階へ自動的に更新するスキル (Todo→In Progress→Done)。複数プロジェクト対応で、Issueが複数のプロジェクトに紐づいている場合、すべてのプロジェクトのステータスを一括更新する。8ステップのプロセスで実装されており、エラーハンドリングと検証を含む。

#### Skill: `update-issue-status`

Location: `.claude/skills/update-issue-status-from-todo-to-in-progress/SKILL.md`

GitHub Issueのステータスを任意のステータスへ更新するスキル。複数プロジェクト対応で、Issueが複数のプロジェクトに紐づいている場合、すべてのプロジェクトのステータスを一括更新する。ユーザーがインタラクティブにステータスを選択でき、エラーハンドリングと検証を含む。

#### Skill: `auto-update-jira-status`

Location: `.claude/skills/jira/auto-update-jira-status/SKILL.md`

Jira Issueのステータスを次の段階へ自動的に更新するスキル (TODO→進行中→完了)。Atlassian MCP Serverを使用してJira APIと連携し、ワークフローの遷移を実行する。ブランチを切るタイミングでの自動ステータス更新に最適。8ステップのプロセスで実装されており、エラーハンドリングと検証を含む。

### 承認済みコマンド

`.claude/settings.local.json`で以下のコマンドを自動承認：

- `Bash(sed:*)` - テキスト処理
- `Bash(gh:*)` - GitHub CLI操作
- `Bash(chmod:*)` - ファイルパーミッション変更
- `Bash(bash:*)` - シェルスクリプト実行
- `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(git checkout:*)`, `Bash(git fetch:*)`, `Bash(git merge:*)` - Git操作
- `Bash(cat:*)` - ファイル内容表示
- `Bash(tree:*)` - ディレクトリ構造表示
- `Skill(update-issue-status-from-todo-to-in-progress)` - 任意ステータス更新スキル（GitHub）
- `Skill(auto-update-issue-status)` - 自動ステータス更新スキル（GitHub）
- `Skill(auto-update-jira-status)` - 自動ステータス更新スキル（Jira）
- `mcp__atlassian__getJiraIssue` - Jiraチケット取得

## Jira Integration

### Jira Management with Atlassian MCP

Atlassian MCP Serverを使用してJiraと統合：

```bash
# Jiraチケットの情報を取得
mcp__atlassian__getJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123")

# 利用可能な遷移を取得
mcp__atlassian__getTransitionsForJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123")

# ステータスを遷移
mcp__atlassian__transitionJiraIssue(cloudId: "site.atlassian.net", issueIdOrKey: "KEY-123", transition: {id: "11"})
```

### 必要な前提条件

- Atlassian MCP Serverが設定されていること（`.mcp.json`で設定）
- Jiraへの認証が完了していること
- 対象チケットへのアクセス権限

### Jiraステータス更新のワークフロー

ブランチを切るタイミングでJiraチケットのステータスを自動更新：

1. Jiraチケット URLから情報を抽出
2. 現在のステータスを取得
3. 利用可能な遷移を取得
4. 次のステータスへの遷移を実行
5. 更新を検証

## GitHub Projects V2 Integration

このリポジトリの主な目的は、GitHub Projects V2とJiraのステータス管理を自動化。

### 必要な前提条件

- GitHub CLIが認証済みであること（`gh auth status`で確認）
- 適切なスコープ（project権限）を持つトークンが設定されていること
- Tasup organizationへのアクセス権限

### Issueステータス更新のワークフロー

Issueのステータスをプログラムマティックに更新する場合：

1. プロジェクトIDとフィールドIDを特定
2. Issue URLからowner/repo/numberを抽出
3. プロジェクトアイテムリストからIssue番号に対応するitem IDを検索
4. `gh project item-edit`コマンドでステータスを更新
5. `gh issue view`で更新を検証

### エラーハンドリング

以下のエラーケースに対応：
- 無効なURL形式
- 存在しないIssue
- プロジェクトに関連付けられていないIssue
- 認証スコープの不足
- ネットワークエラー
