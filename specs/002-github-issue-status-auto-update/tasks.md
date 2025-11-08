# 実装計画

## 概要

この実装計画は、GitHub Issue Status Auto Update機能をTDD原則に従って段階的に実装するためのタスクリストです。Claude CodeのSlash Commandとして実装し、GitHub issue URLを指定してステータスを「TODO」から「IN_PROGRESS」に自動更新する機能を提供します。

実装は機能単位で整理し、各コンポーネント内で実装→テストの順序で進めます。

## タスクリスト

- [ ] 1. プロジェクト基盤のセットアップ
  - [ ] 1.1 ディレクトリ構造の作成
    - `.claude/commands/` ディレクトリを作成
    - `.claude/libs/` ディレクトリを作成（共通ライブラリ用）
    - `tests/` ディレクトリを作成
    - _Requirements: 全般_

  - [ ] 1.2 テストフレームワークのセットアップ
    - `bats` (Bash Automated Testing System) のインストール確認
    - テスト実行用のヘルパースクリプト作成
    - テスト用のモックヘルパー作成（`tests/helpers/mocks.bash`）
    - _Requirements: 全般_

- [ ] 2. URL Parser の実装
  - [ ] 2.1 URL解析ライブラリの実装
    - `.claude/libs/url_parser.bash` ファイルを作成
    - `parse_github_issue_url()` 関数を実装
      - 入力: GitHub issue URL (例: `https://github.com/owner/repo/issues/123`)
      - 出力: owner, repo, issueNumber を抽出
      - エラーハンドリング: 無効なURL形式の検出
    - テスト: `tests/url_parser.bats` を作成
      - 正常系: 有効なURL形式の解析テスト
      - 異常系: 無効なURL形式の検出テスト（プロトコルなし、issue番号なし、GitHub以外のURL等）
      - エッジケース: 異なるGitHub URL形式のテスト
    - _Requirements: 1.2, 1.3_

- [ ] 3. GitHub API Client の実装
  - [ ] 3.1 認証確認機能の実装
    - `.claude/libs/github_client.bash` ファイルを作成
    - `check_gh_auth()` 関数を実装
      - `gh auth status` を使用して認証状態を確認
      - 未認証の場合は適切なエラーメッセージを返す
    - テスト: `tests/github_client_auth.bats` を作成
      - 正常系: 認証済みの場合のテスト
      - 異常系: 未認証の場合のエラーメッセージテスト
    - _Requirements: 1.4_

  - [ ] 3.2 Issue情報取得機能の実装
    - `get_issue_info()` 関数を `.claude/libs/github_client.bash` に実装
      - `gh api` を使用してissue情報を取得
      - issueが存在しない場合のエラーハンドリング
      - 権限がない場合のエラーハンドリング
    - テスト: `tests/github_client_issue.bats` を作成
      - 正常系: issue情報取得のテスト
      - 異常系: 存在しないissueのエラーテスト、権限エラーのテスト
    - _Requirements: 1.3_

  - [ ] 3.3 GraphQL実行機能の実装
    - `execute_graphql()` 関数を `.claude/libs/github_client.bash` に実装
      - `gh api graphql` を使用してGraphQLクエリを実行
      - エラーハンドリング: APIエラーの検出と適切なメッセージ
    - テスト: `tests/github_client_graphql.bats` を作成
      - 正常系: GraphQLクエリ実行のテスト
      - 異常系: APIエラーのハンドリングテスト
    - _Requirements: 4.1, 4.2_

  - [ ] 3.4 プロジェクト情報取得機能の実装
    - `get_issue_projects()` 関数を `.claude/libs/github_client.bash` に実装
      - GraphQLを使用してissueが関連付けられているプロジェクトを取得
      - プロジェクトのステータスフィールド情報を取得
      - 複数プロジェクトに対応
    - テスト: `tests/github_client_projects.bats` を作成
      - 正常系: 単一プロジェクト取得のテスト
      - 正常系: 複数プロジェクト取得のテスト
      - 異常系: ステータスフィールドが存在しない場合の警告テスト
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 4. Issue Status Updater の実装
  - [ ] 4.1 ステータス更新ロジックの実装
    - `.claude/libs/status_updater.bash` ファイルを作成
    - `update_issue_status()` 関数を実装
      - 現在のステータスを確認（GitHub Projects V2から取得）
      - ステータスが「TODO」の場合のみ「IN_PROGRESS」に更新
      - 既に「IN_PROGRESS」の場合は処理をスキップ
      - GraphQL mutationを使用してプロジェクトステータスを更新
    - テスト: `tests/status_updater.bats` を作成
      - 正常系: TODOからIN_PROGRESSへの更新テスト
      - 正常系: 既にIN_PROGRESSの場合のスキップテスト
      - 異常系: GraphQL APIエラーのハンドリングテスト
    - _Requirements: 1.1, 1.5, 2.3, 3.3_

  - [ ] 4.2 複数プロジェクト対応の実装
    - `update_all_project_statuses()` 関数を `.claude/libs/status_updater.bash` に実装
      - issueが関連付けられているすべてのプロジェクトのステータスを更新
      - 1つのプロジェクト更新失敗でも他は継続
      - 更新結果のサマリーを返す
    - テスト: `tests/status_updater_multi.bats` を作成
      - 正常系: 複数プロジェクト更新のテスト
      - 異常系: 一部プロジェクト更新失敗時の継続テスト
    - _Requirements: 4.2_

- [ ] 5. Git Branch Manager の実装
  - [ ] 5.1 ブランチ作成機能の実装
    - `.claude/libs/git_manager.bash` ファイルを作成
    - `create_branch_and_update_status()` 関数を実装
      - ブランチ名の検証
      - `git checkout -b <branch-name>` を実行
      - ブランチ作成成功後、`update_issue_status()` を呼び出し
      - ブランチ作成失敗時はステータス更新を実行しない
    - テスト: `tests/git_manager_branch.bats` を作成
      - 正常系: ブランチ作成成功時のステータス更新確認
      - 異常系: ブランチ作成失敗時のステータス未更新確認
      - 異常系: ブランチ名が既に存在する場合のエラーテスト
    - _Requirements: 2.1, 2.2_

- [ ] 6. Git Commit Manager の実装
  - [ ] 6.1 コミット後のステータス更新機能の実装
    - `commit_and_update_status()` 関数を `.claude/libs/git_manager.bash` に実装
      - ステージされたファイルの確認
      - コミット実行（`git commit` を使用）
      - コミット成功後、`update_issue_status()` を呼び出し
      - コミット失敗時はステータス更新を実行しない
    - テスト: `tests/git_manager_commit.bats` を作成
      - 正常系: コミット成功時のステータス更新確認
      - 異常系: コミット失敗時のステータス未更新確認
      - 異常系: ステージされたファイルがない場合のエラーテスト
    - _Requirements: 3.1, 3.2_

- [ ] 7. Slash Command Entry Point の実装
  - [ ] 7.1 コマンドファイルの作成
    - `.claude/commands/update-issue-status.md` ファイルを作成
    - コマンドの説明とインターフェースを定義
    - 使用方法の例を記載
      - 基本的な使用法: `/update-issue-status <GitHub Issue URL>`
      - ブランチ作成と同時: `/update-issue-status <URL> --branch <branch-name>`
      - コミット後の更新: `/update-issue-status <URL> --commit`
    - _Requirements: 1.1, 2.1, 3.1_

  - [ ] 7.2 コマンドロジックの実装
    - `.claude/libs/command_handler.bash` ファイルを作成
    - `handle_update_issue_status()` 関数を実装
      - コマンドライン引数の解析（issue URL、オプション）
      - オプションに応じた適切な処理の呼び出し
        - `--branch`: `create_branch_and_update_status()` を呼び出し
        - `--commit`: `commit_and_update_status()` を呼び出し
        - オプションなし: `update_issue_status()` を直接呼び出し
      - すべてのライブラリ関数の統合
      - エラーハンドリングとユーザーフィードバック
    - テスト: `tests/command_handler.bats` を作成
      - 正常系: 各オプションでのコマンド実行テスト
      - 異常系: 無効なオプションのエラーテスト
      - 異常系: 必須引数欠如のエラーテスト
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3_

- [ ] 8. 統合テストの実装
  - [ ] 8.1 エンドツーエンドフローのテスト
    - `tests/integration/e2e_flow.bats` ファイルを作成
    - コマンド入力から完了までのフロー全体をテスト
      - シナリオ1: URL指定のみでのステータス更新
      - シナリオ2: ブランチ作成と同時のステータス更新
      - シナリオ3: コミット作成と同時のステータス更新
    - エラー時の適切なフィードバック確認
    - 複数プロジェクトに関連付けられたissueの更新確認
    - _Requirements: 全ての要件_

  - [ ] 8.2 エラーシナリオの統合テスト
    - `tests/integration/error_scenarios.bats` ファイルを作成
    - 主要なエラーシナリオをテスト
      - 無効なURL形式でのエラー
      - 存在しないissueでのエラー
      - 未認証状態でのエラー
      - 権限不足でのエラー
      - ブランチ作成失敗時のロールバック
      - コミット作成失敗時のロールバック
    - _Requirements: 1.2, 1.3, 1.4, 2.2, 3.2_

- [ ] 9. ドキュメントとサンプルの作成
  - [ ] 9.1 使用方法ドキュメントの作成
    - `docs/usage.md` ファイルを作成
    - インストール方法を記載
    - 基本的な使用例を記載
    - 各オプションの詳細な説明を記載
    - トラブルシューティングガイドを記載
    - _Requirements: 全般_

  - [ ] 9.2 サンプルワークフローの作成
    - `examples/` ディレクトリを作成
    - 典型的な開発ワークフローの例を記載
      - issue作成からブランチ作成、実装、PR作成までの流れ
      - コマンドの実際の使用例
    - _Requirements: 全般_

## 実装の注意事項

- **テスト駆動開発**: 各機能の実装前にテストを作成し、実装後に実行
- **モジュール化**: 各コンポーネントを独立したファイルとして実装し、再利用性を高める
- **エラーハンドリング**: すべてのエラーケースを適切に処理し、わかりやすいメッセージをユーザーに提供
- **GitHub CLI活用**: `gh` コマンドを最大限活用し、認証管理とAPI操作を簡素化
- **日本語メッセージ**: すべてのユーザー向けメッセージは日本語で提供
- **段階的な実装**: 各タスクは前のタスクに基づいて構築され、最終的に統合される

## 要件カバレッジ

このタスクリストは以下の要件をすべてカバーしています：

- **要件1**: URL指定によるステータス更新（タスク2, 3, 4, 7）
- **要件2**: ブランチ作成と同時のステータス更新（タスク5, 7）
- **要件3**: コミット作成と同時のステータス更新（タスク6, 7）
- **要件4**: GitHub Projectsのステータスフィールド対応（タスク3.4, 4）
