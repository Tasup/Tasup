# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tasupは、GitHub Projects V2とGitHub Issuesの統合を管理するためのClaude Code設定リポジトリです。主にGitHub CLIコマンドを使用して、Issueのステータスを自動的に更新するワークフローを提供します。

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

このリポジトリは以下のClaude Code拡張機能を提供します：

#### Slash Command: `/issue-progress`

Location: `.claude/commands/issue-progress.md`

GitHub IssueのステータスをGitHub Projects V2で「In progress」に更新するコマンド。GraphQL APIとgh CLIを組み合わせて、以下のプロセスで動作します：

1. Issue URLから情報を抽出
2. GraphQL APIでプロジェクト情報を取得（item_id, project_id, field_id, option_id）
3. 現在のステータスを確認
4. 既に「In progress」の場合はスキップ
5. `gh project item-edit`コマンドでステータスを更新
6. 更新結果を検証

#### Skill: `update-issue-status-from-todo-to-in-progress`

Location: `.claude/skills/update-issue-status-from-todo-to-in-progress/SKILL.md`

GitHub IssueのステータスをTODOからIN_PROGRESSに更新するスキル。7ステップのプロセスで実装されており、エラーハンドリングと検証を含みます。

### 承認済みコマンド

`.claude/settings.local.json`で以下のコマンドが自動承認されています：

- `Bash(sed:*)` - テキスト処理
- `Bash(gh:*)` - GitHub CLI操作
- `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(git push:*)` - Git操作
- `Skill(update-issue-status-from-todo-to-in-progress.md)` - Issue更新スキル
- `Bash(tree:*)` - ディレクトリ構造表示

## GitHub Projects V2 Integration

このリポジトリの主な目的は、GitHub Projects V2のステータス管理を自動化することです。

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
