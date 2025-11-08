# GitHub Issue Status Auto Update

GitHub IssueのステータスをGitHub Projects V2で自動的に「Todo」から「In Progress」に更新するBashベースのコマンドラインツールです。

## 概要

このツールは、開発ワークフローの効率化を目的として作成されました。GitHub issueに着手する際、手動でプロジェクトボードのステータスを変更する手間を省き、コマンド一つでステータスを更新できます。

### 主な機能

- **自動ステータス更新**: GitHub issue URLを指定するだけで、関連するプロジェクトのステータスを「Todo」から「In Progress」に更新
- **ブランチ作成との統合**: 新しいGitブランチを作成すると同時にissueステータスを更新
- **複数プロジェクト対応**: 1つのissueが複数のプロジェクトに関連付けられている場合、すべてのプロジェクトのステータスを更新
- **スマートな更新**: 既に「In Progress」の場合は更新をスキップし、不要な操作を防止

## 必要な環境

- **GitHub CLI (`gh`)**: バージョン2.0以上
  - インストール: `brew install gh` (macOS) または [公式サイト](https://cli.github.com/)からダウンロード
  - 認証済みであること: `gh auth login`
- **Git**: バージョン2.0以上
- **Bash**: バージョン4.0以上
- **対象リポジトリとプロジェクトへのアクセス権限**

## インストール

このツールは既にプロジェクトの`.claude/libs/`ディレクトリにインストールされています。追加のインストール作業は不要です。

## 使用方法

### 基本的な使用方法

GitHub issue URLを指定してステータスを更新します：

```bash
bash .claude/libs/command_handler.bash https://github.com/owner/repo/issues/123
```

実行例：
```bash
$ bash .claude/libs/command_handler.bash https://github.com/Tasup/Tasup/issues/42
GitHub認証を確認中...
認証成功: GitHub CLIは正常に認証されています。
Issue情報を取得中...
プロジェクト情報を取得中...
プロジェクト「Development Board」のステータスを「Todo」から「In Progress」に更新しています...
成功: プロジェクト「Development Board」のステータスを「In Progress」に更新しました。
```

### ブランチ作成と同時にステータスを更新

新しいブランチを作成すると同時にissueステータスを更新します：

```bash
bash .claude/libs/command_handler.bash https://github.com/owner/repo/issues/123 --branch feature/add-login
```

実行例：
```bash
$ bash .claude/libs/command_handler.bash https://github.com/Tasup/Tasup/issues/42 --branch feature/implement-auth
ブランチ名を検証中...
ブランチを作成中...
成功: ブランチ「feature/implement-auth」を作成しました。
GitHub認証を確認中...
認証成功: GitHub CLIは正常に認証されています。
Issue情報を取得中...
プロジェクト情報を取得中...
プロジェクト「Development Board」のステータスを「Todo」から「In Progress」に更新しています...
成功: プロジェクト「Development Board」のステータスを「In Progress」に更新しました。
```

### ヘルプの表示

使用方法を確認するには：

```bash
bash .claude/libs/command_handler.bash --help
```

## アーキテクチャ

このツールは、以下のモジュールで構成されています：

### コアライブラリ

#### 1. `url_parser.bash`
- **役割**: GitHub issue URLの解析と検証
- **主要関数**:
  - `parse_github_issue_url()`: URLからowner、repo、issue番号を抽出
  - `validate_github_issue_url()`: URL形式の妥当性を検証

#### 2. `github_client.bash`
- **役割**: GitHub APIとの通信を管理
- **主要関数**:
  - `check_gh_auth()`: GitHub CLI認証状態を確認
  - `get_issue_info()`: REST APIでissue情報を取得
  - `execute_graphql()`: GraphQLクエリを実行
  - `get_issue_projects()`: issueに関連するプロジェクト情報を取得

#### 3. `status_updater.bash`
- **役割**: プロジェクトステータスの更新ロジック
- **主要関数**:
  - `update_issue_status()`: ステータスを「Todo」から「In Progress」に更新
  - `update_all_project_statuses()`: 複数プロジェクトのステータスを一括更新

#### 4. `git_manager.bash`
- **役割**: Git操作とステータス更新の統合
- **主要関数**:
  - `create_branch_and_update_status()`: ブランチ作成後にステータスを更新

#### 5. `command_handler.bash`
- **役割**: コマンドラインエントリーポイント
- **機能**: 引数解析、適切な関数の呼び出し、エラーハンドリング

### データフロー

```
ユーザー入力
    ↓
command_handler.bash (引数解析)
    ↓
url_parser.bash (URL検証・解析)
    ↓
github_client.bash (認証確認)
    ↓
git_manager.bash (オプション: ブランチ作成)
    ↓
github_client.bash (プロジェクト情報取得)
    ↓
status_updater.bash (ステータス更新)
    ↓
完了
```

## テスト

### テストの実行

すべてのテストを実行するには：

```bash
bash tests/run_tests.sh
```

特定のテストのみを実行するには：

```bash
bash tests/url_parser.test.bash
bash tests/github_client_auth.test.bash
bash tests/status_updater.test.bash
# など
```

### テストカバレッジ

- **URL Parser**: 10テストケース
- **GitHub Client (認証)**: 3テストケース
- **GitHub Client (Issue)**: 5テストケース
- **GitHub Client (GraphQL)**: 5テストケース
- **GitHub Client (Projects)**: 5テストケース
- **Status Updater**: 5テストケース
- **Git Manager**: 6テストケース
- **Command Handler**: 6テストケース

**合計**: 45テストケース

### テストフレームワーク

カスタムBashテストフレームワークを使用しています：

- `tests/helpers/test_helper.bash`: テストユーティリティ関数
- `tests/helpers/mocks.bash`: GitHub CLIとGitコマンドのモック

## トラブルシューティング

### 認証エラー

**エラーメッセージ**:
```
エラー: GitHub CLIが認証されていません。
```

**解決方法**:
```bash
gh auth login
```

GitHub CLIの認証を完了してから、再度コマンドを実行してください。

### URLフォーマットエラー

**エラーメッセージ**:
```
エラー: 無効なGitHub issue URLです。正しい形式: https://github.com/owner/repo/issues/123
```

**解決方法**:
- URLが正しい形式であることを確認してください
- 正しい形式: `https://github.com/owner/repo/issues/123`
- 間違った形式: `github.com/owner/repo/issues/123` (プロトコルなし)

### Issueが見つからない

**エラーメッセージ**:
```
エラー: Issue情報の取得に失敗しました。
```

**原因と解決方法**:
1. **Issueが存在しない**: URLのissue番号を確認してください
2. **アクセス権限がない**: リポジトリへのアクセス権限を確認してください
3. **プライベートリポジトリ**: 正しい認証情報でログインしているか確認してください

### ブランチ作成エラー

**エラーメッセージ**:
```
エラー: ブランチの作成に失敗しました。
```

**原因と解決方法**:
1. **ブランチ名が既に存在**: 別のブランチ名を使用してください
2. **無効なブランチ名**: 英数字、ハイフン、スラッシュのみを使用してください（`@`などの特殊文字は使用不可）
3. **Gitリポジトリではない**: Gitリポジトリ内で実行していることを確認してください

### プロジェクトが関連付けられていない

**警告メッセージ**:
```
警告: Issue #123 はどのプロジェクトにも関連付けられていません。
```

**解決方法**:
GitHub上で、issueを少なくとも1つのプロジェクトに関連付けてください。

### ステータスフィールドが見つからない

**エラーメッセージ**:
```
エラー: プロジェクトにStatusフィールドが見つかりません。
```

**解決方法**:
GitHub Projects V2で、プロジェクトに「Status」フィールドが設定されていることを確認してください。

## よくある質問 (FAQ)

### Q: 複数のプロジェクトに関連付けられたissueはどうなりますか?

A: すべてのプロジェクトのステータスが更新されます。1つのプロジェクトで更新が失敗しても、他のプロジェクトの更新は継続されます。

### Q: 既に「In Progress」のissueを更新するとどうなりますか?

A: 更新はスキップされ、「既にIn Progressです」というメッセージが表示されます。

### Q: ステータスフィールドの名前が「Status」でない場合は?

A: 現在のバージョンでは「Status」という名前のフィールドを探します。カスタムフィールド名のサポートは今後の改善予定です。

### Q: GitHub Projects V1には対応していますか?

A: いいえ、このツールはGitHub Projects V2専用です。Projects V1は非推奨となっています。

### Q: 「Todo」以外のステータスから「In Progress」に更新できますか?

A: 現在のバージョンでは「Todo」から「In Progress」への更新のみサポートしています。他のステータス遷移のサポートは今後の改善予定です。

## 開発ドキュメント

詳細な開発ドキュメントは以下を参照してください：

- **設計書**: `specs/002-github-issue-status-auto-update/design.md`
- **要件定義**: `specs/002-github-issue-status-auto-update/requirements.md`
- **実装計画**: `specs/002-github-issue-status-auto-update/tasks.md`

## ライセンス

このツールはプロジェクトのライセンスに従います。

## 貢献

改善提案やバグレポートは、GitHubのissueで受け付けています。

## 変更履歴

### v1.0.0 (2025-11-08)
- 初回リリース
- 基本的なステータス更新機能
- ブランチ作成との統合
- 複数プロジェクト対応
- 包括的なテストスイート
