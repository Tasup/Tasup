GitHub IssueのステータスをTODOからIN_PROGRESSに更新します。

このコマンドは、指定されたGitHub IssueのステータスをGitHub Projects V2で「Todo」から「In Progress」に更新します。
オプションでブランチ作成と同時にステータスを更新することもできます。

# 使用方法

## 基本的な使用方法

```bash
bash .claude/libs/command_handler.bash <GitHub Issue URL>
```

例:
```bash
bash .claude/libs/command_handler.bash https://github.com/owner/repo/issues/123
```

## ブランチ作成と同時にステータスを更新

```bash
bash .claude/libs/command_handler.bash <GitHub Issue URL> --branch <branch-name>
```

例:
```bash
bash .claude/libs/command_handler.bash https://github.com/owner/repo/issues/123 --branch feature/add-login
```

## 機能

- GitHub issue URLを解析してowner、repo、issue番号を抽出
- GitHub Projects V2から現在のステータスを取得
- ステータスが「Todo」の場合のみ「In Progress」に更新
- 既に「In Progress」の場合はスキップ
- プロジェクトが関連付けられていない場合は警告を表示
- 複数のプロジェクトに関連付けられている場合、すべて更新

## 必要な環境

- GitHub CLI (`gh`) がインストールされ、認証済みであること
- 対象のリポジトリとプロジェクトへのアクセス権限があること

## エラーメッセージ

- 無効なURL形式の場合: URLの形式を確認してください
- 認証エラーの場合: `gh auth login` を実行してください
- Issueが存在しない場合: URLが正しいか確認してください
- 権限エラーの場合: リポジトリへのアクセス権限を確認してください
