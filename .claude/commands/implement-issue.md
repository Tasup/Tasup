GitHub Issueの実装を計画・実行します。

指定されたGitHub Issueの内容を読み込み、適切なブランチを作成し、ステータスを更新した後、実装計画を立てて実装を進めます。

---

以下のGitHub Issueを実装してください：

{{ args }}

## 実装手順

### 1. GitHub Issue URL のパース

Issue URL から以下の情報を抽出してください：
- Organization/Owner名
- Repository名
- Issue番号

URLフォーマット: `https://github.com/{org}/{repository}/{issues|pull}/{number}`

### 2. Issue 詳細の取得

`gh issue view` コマンドを使用してIssueの詳細を取得してください：

```bash
gh issue view {issue_number} --repo {org}/{repository} --json title,body,number
```

Issueのタイトルと本文を確認し、実装内容を理解してください。

### 3. ブランチ名の生成

Issueの内容から実装内容を理解し、以下の形式でブランチ名を生成してください：

**フォーマット**: `{repository_name}-{issue_number}-{implement-content}`

**ブランチ名のルール**:
- `{implement-content}` は **必ず40文字以内** で記述
- Issueのタイトルと本文から実装内容を理解し、簡潔に要約
- ケバブケース形式（小文字、ハイフン区切り）を使用
- 英数字とハイフンのみ使用（日本語やスペースは不可）

**良い例**:
- `tasup-42-add-user-authentication`
- `frontend-15-fix-responsive-layout`
- `api-23-implement-rate-limiting`

**悪い例**:
- `tasup-42-this-is-a-very-long-description-that-exceeds-forty-characters-limit` (40文字超過)
- `tasup-42-ユーザー認証追加` (日本語を含む)
- `tasup-42-add user auth` (スペースを含む)

### 4. ブランチの作成と切り替え

生成したブランチ名で新しいブランチを作成し、切り替えてください：

```bash
git checkout -b {生成したブランチ名}
```

**エラーハンドリング**:
- 同名のブランチが既に存在する場合は、エラーメッセージを表示し、異なる名前を提案してください
- 現在のブランチに未コミットの変更がある場合は、ユーザーに通知してください

### 5. Issue ステータスの更新

`auto-update-issue-status` スキルを使用して、Issueのステータスを "In Progress" に更新してください。

**手順**:
1. `Skill(auto-update-issue-status)` を実行
2. Issue URLを指定
3. ステータス選択で "In Progress" を選択

**注意事項**:
- Issueがプロジェクトに紐付いていない場合は、ステータス更新をスキップし、その旨をユーザーに通知
- 既に "In Progress" の場合は、更新をスキップ
- GitHub CLI認証エラーが発生した場合は、`gh auth status` で認証状態を確認するようユーザーに促す

### 6. タスクプランの作成

TodoWrite ツールを使用して、Issueの実装に必要なタスクリストを作成してください。

**タスク分解のガイドライン**:
- Issueの内容を分析し、具体的で実行可能なタスクに分解
- 各タスクは明確な完了条件を持つこと
- 依存関係を考慮した順序でタスクを配置
- 必要に応じて、設計・実装・テスト・ドキュメント更新などのフェーズに分ける

**タスク例**:
```
1. データモデルの設計と実装
2. API エンドポイントの実装
3. フロントエンドコンポーネントの作成
4. ユニットテストの作成
5. 統合テストの実行
6. ドキュメントの更新
```

### 7. ユーザーへの確認

作成したタスクプランをユーザーに提示し、確認を求めてください。

**確認メッセージの形式**:
```
以下の実装プランで進めます。問題なければ「y」または「ok」を入力してください：

[TodoWriteで作成したタスクリストの概要]

ブランチ: {生成したブランチ名}
Issue: #{issue_number} - {issue_title}
ステータス: In Progress

続行しますか？ (y/ok で続行)
```

### 8. 実装の実行

ユーザーから "y" または "ok" の確認を受け取った後、TodoWriteのタスクリストに従って実装を進めてください。

**実装中の注意事項**:
- 各タスクを in_progress にマークしてから作業開始
- タスク完了後、すぐに completed にマーク
- 問題が発生した場合は、新しいタスクを追加するか、ユーザーに確認
- セキュリティ脆弱性（XSS, SQL Injection, コマンドインジェクションなど）に注意
- コーディング規約とベストプラクティスに従う

**実装完了後**:
- すべてのタスクが completed になったことを確認
- テストが成功していることを確認
- ビルドエラーがないことを確認
- 実装完了をユーザーに報告

**注意**: このコマンドは実装のみを行い、コミットやPR作成は行いません。実装完了後、ユーザーが手動でコミットとPRを作成してください。

## エラーハンドリング

### 無効なURL形式
- GitHub Issue URLの形式が正しくない場合は、エラーメッセージを表示し、正しい形式を案内

### Issue が存在しない
- 指定されたIssueが見つからない場合は、Issue番号とリポジトリを確認するようユーザーに促す

### ブランチ名の重複
- 同名のブランチが既に存在する場合は、別の名前を提案するか、既存ブランチに切り替えるかユーザーに確認

### GitHub CLI 認証エラー
- 認証が必要な場合は、`gh auth login` を実行するようユーザーに案内
- 必要なスコープ（repo, project）が不足している場合は、再認証を促す

### プロジェクトに紐付いていない Issue
- ステータス更新がスキップされた場合は、その旨をユーザーに通知
- 必要に応じて手動でIssueをプロジェクトに追加するよう案内

## 実装例

```bash
# コマンド実行
/implement-issue https://github.com/Tasup/frontend/issues/42

# 実行される処理:
# 1. Issue #42 の詳細を取得
# 2. ブランチ "frontend-42-add-user-authentication" を作成
# 3. Issue ステータスを "In Progress" に更新
# 4. 実装タスクリストを作成・表示
# 5. ユーザー確認後、実装開始
```

## 参考情報

- GitHub CLI ドキュメント: https://cli.github.com/manual/
- プロジェクトステータス更新: `.claude/skills/auto-update-issue-status/SKILL.md`
- GitHub CLI コマンド: `.claude/skills/gh-commands.md`
