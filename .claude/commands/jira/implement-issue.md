Jira Issueの実装を計画・実行します。

指定されたJira Issueの内容を読み込み、適切なブランチを作成し、ステータスを更新した後、実装計画を立てて実装を進めます。

---

以下のJira Issueを実装してください：

{{ args }}

## 実装手順

### 1. Jira Issue URL のパース

Issue URL から以下の情報を抽出してください：
- Cloud ID (Atlassian site URL)
- Issue Key (例: PROJ-123)

URLフォーマット: `https://{site}.atlassian.net/browse/{ISSUE-KEY}`

### 2. Issue 詳細の取得

`mcp__atlassian__getJiraIssue` ツールを使用してIssueの詳細を取得してください：

```
mcp__atlassian__getJiraIssue(cloudId: "{site}.atlassian.net", issueIdOrKey: "{ISSUE-KEY}")
```

Issueのサマリー、説明、現在のステータスを確認し、実装内容を理解してください。

### 3. ブランチ名の生成

Issueの内容から実装内容を理解し、以下の形式でブランチ名を生成してください：

**フォーマット**: `{issue-key}-{implement-content}`

**ブランチ名のルール**:
- `{issue-key}` はIssue Keyをそのまま使用（例: `PROJ-123`）大文字を保持
- `{implement-content}` は **必ず40文字以内** で記述
- Issueのサマリーと説明から実装内容を理解し、簡潔に要約
- `{implement-content}` 部分はケバブケース形式（小文字、ハイフン区切り）を使用
- 英数字とハイフンのみ使用（日本語やスペースは不可）

**良い例**:
- `PROJ-123-add-user-authentication`
- `PROJ-456-implement-api-sync`
- `TEAM-789-fix-auth-flow`

**悪い例**:
- `PROJ-123-this-is-a-very-long-description-that-exceeds-forty-characters-limit` (40文字超過)
- `PROJ-123-受信データ変換` (日本語を含む)
- `PROJ-123-add transform api` (スペースを含む)

### 4. ブランチの作成と切り替え

生成したブランチ名で新しいブランチを作成し、切り替えてください：

```bash
git checkout -b {生成したブランチ名}
```

**エラーハンドリング**:
- 同名のブランチが既に存在する場合は、エラーメッセージを表示し、異なる名前を提案してください
- 現在のブランチに未コミットの変更がある場合は、ユーザーに通知してください

### 5. Issue ステータスの更新

`auto-update-jira-status` スキルを使用して、Issueのステータスを "進行中" に更新してください。

**手順**:
1. `Skill(auto-update-jira-status)` を実行
2. Issue URLを指定
3. 自動的に次のステータス（通常は「進行中」）に遷移

**注意事項**:
- 既に "進行中" の場合は、更新をスキップ
- Atlassian MCP Serverの認証エラーが発生した場合は、認証状態を確認するようユーザーに促す
- 利用可能な遷移がない場合は、その旨をユーザーに通知

### 6. タスクプランの作成

TodoWrite ツールを使用して、Issueの実装に必要なタスクリストを作成してください。

**タスク分解のガイドライン**:
- Issueの内容（description、受入条件）を分析し、具体的で実行可能なタスクに分解
- 各タスクは明確な完了条件を持つこと
- 依存関係を考慮した順序でタスクを配置
- 必要に応じて、設計・実装・テスト・ドキュメント更新などのフェーズに分ける

**タスク例**:
```
1. 既存の実装を参考に設計方針を決定
2. APIコントローラーの実装
3. サービスクラスの実装
4. エラーハンドリングの追加
5. ユニットテストの作成
6. 統合テストの実行
7. ドキュメントの更新
```

### 7. ユーザーへの確認

作成したタスクプランをユーザーに提示し、確認を求めてください。

**確認メッセージの形式**:
```
以下の実装プランで進めます。問題なければ「y」または「ok」を入力してください：

[TodoWriteで作成したタスクリストの概要]

ブランチ: {生成したブランチ名}
Issue: {ISSUE-KEY} - {issue_summary}
ステータス: 進行中

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
- Jira Issue URLの形式が正しくない場合は、エラーメッセージを表示し、正しい形式を案内

### Issue が存在しない
- 指定されたIssueが見つからない場合は、Issue KeyとサイトURLを確認するようユーザーに促す

### ブランチ名の重複
- 同名のブランチが既に存在する場合は、別の名前を提案するか、既存ブランチに切り替えるかユーザーに確認

### Atlassian MCP 認証エラー
- 認証が必要な場合は、Atlassian MCP Serverの設定を確認するようユーザーに案内
- `.mcp.json` が正しく設定されているか確認

### 遷移が利用できない Issue
- ステータス遷移が利用できない場合は、その旨をユーザーに通知
- Jiraのワークフロー設定を確認するよう案内

## 実装例

```bash
# コマンド実行
/jira/implement-issue https://your-site.atlassian.net/browse/PROJ-123

# 実行される処理:
# 1. Issue PROJ-123 の詳細を取得
# 2. ブランチ "PROJ-123-add-user-authentication" を作成
# 3. Issue ステータスを "進行中" に更新
# 4. 実装タスクリストを作成・表示
# 5. ユーザー確認後、実装開始
```

## 参考情報

- Atlassian MCP Server: `.mcp.json`
- Jiraステータス更新スキル: `.claude/skills/auto-update-jira-status/SKILL.md`
- Jira統合ドキュメント: `CLAUDE.md` (Jira Integration セクション)
