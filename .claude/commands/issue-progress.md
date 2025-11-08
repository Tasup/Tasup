GitHub IssueのステータスをIn Progressに更新します。

指定されたGitHub IssueのステータスをGitHub Projects V2で「In progress」に更新します。
`gh project item-edit`コマンドを使用してシンプルに実装しています。

---

以下のGitHub Issue URLのステータスを「In progress」に更新してください：

{{ args }}

手順：
1. GraphQL APIでissueのプロジェクト情報を取得（item_id, project_id, current_status, field_id, in_progress_option_idを取得）
2. 現在のステータスを確認
3. 既に「In progress」の場合はスキップ
4. `gh project item-edit`コマンドでステータスを更新
5. 更新結果を確認して報告

注意：
- プロジェクトに関連付けられていないissueの場合は警告を表示
- jqコマンドを使用してJSON解析を行う
- エラーが発生した場合は詳細なメッセージを表示
