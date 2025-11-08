#!/usr/bin/env bash

# Status Updater Tests
# ステータス更新ロジックのテスト

set -euo pipefail

# テストヘルパーとモックをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/helpers/test_helper.bash
source "${SCRIPT_DIR}/helpers/test_helper.bash"
# shellcheck source=tests/helpers/mocks.bash
source "${SCRIPT_DIR}/helpers/mocks.bash"

# Status Updaterライブラリをロード
PROJECT_ROOT=$(get_project_root)
# shellcheck source=.claude/libs/status_updater.bash
source "${PROJECT_ROOT}/.claude/libs/status_updater.bash"

echo "========================================="
echo "  Status Updater Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: TODOからIN_PROGRESSへの更新
test_update_from_todo_to_in_progress() {
  setup

  # TODOステータスのプロジェクト情報をモック
  local response_file
  response_file=$(create_mock_response_file "status_todo.json" '{
    "data": {
      "repository": {
        "issue": {
          "projectItems": {
            "nodes": [
              {
                "id": "PVTI_123",
                "project": {
                  "id": "PVT_abc",
                  "title": "Test Project"
                },
                "fieldValues": {
                  "nodes": [
                    {
                      "name": "Todo",
                      "field": {
                        "id": "PVTF_status",
                        "name": "Status",
                        "options": [
                          {"id": "todo_id", "name": "Todo"},
                          {"id": "in_progress_id", "name": "In Progress"},
                          {"id": "done_id", "name": "Done"}
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
  }')

  mock_gh_graphql_success "${response_file}"

  run_command update_issue_status "owner" "repo" "123"

  teardown

  # ステータス更新のメッセージが出力されることを確認
  assert_contains "${output}" "Todoから" || assert_contains "${output}" "更新しました" || return 1
  # 成功することを確認
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected update_issue_status to succeed" >&2
    return 1
  fi
}

# テスト2: 既にIN_PROGRESSの場合のスキップ
test_skip_already_in_progress() {
  setup

  # IN_PROGRESSステータスのプロジェクト情報をモック
  local response_file
  response_file=$(create_mock_response_file "status_in_progress.json" '{
    "data": {
      "repository": {
        "issue": {
          "projectItems": {
            "nodes": [
              {
                "id": "PVTI_123",
                "project": {
                  "id": "PVT_abc",
                  "title": "Test Project"
                },
                "fieldValues": {
                  "nodes": [
                    {
                      "name": "In Progress",
                      "field": {
                        "id": "PVTF_status",
                        "name": "Status",
                        "options": [
                          {"id": "todo_id", "name": "Todo"},
                          {"id": "in_progress_id", "name": "In Progress"},
                          {"id": "done_id", "name": "Done"}
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
  }')

  mock_gh_graphql_success "${response_file}"

  run_command update_issue_status "owner" "repo" "456"

  teardown

  # スキップメッセージが出力されることを確認
  assert_contains "${output}" "In Progress" || return 1
  assert_contains "${output}" "スキップ" || return 1
  # 成功することを確認
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected update_issue_status to succeed with skip" >&2
    return 1
  fi
}

# テスト3: プロジェクトが関連付けられていない場合
test_no_project_associated() {
  setup

  # プロジェクトなしのレスポンスモック
  local response_file
  response_file=$(create_mock_response_file "status_no_project.json" '{
    "data": {
      "repository": {
        "issue": {
          "projectItems": {
            "nodes": []
          }
        }
      }
    }
  }')

  mock_gh_graphql_success "${response_file}"

  run_command update_issue_status "owner" "repo" "789"

  teardown

  # プロジェクトなしのメッセージが出力されることを確認
  assert_contains "${output}" "プロジェクトに関連付けられていません" || return 1
  # 成功することを確認
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected update_issue_status to succeed with no project" >&2
    return 1
  fi
}

# テスト4: 引数不足エラー
test_missing_arguments() {
  run_command update_issue_status "owner" "repo"

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "owner、repo、issue_numberが必要です" || return 1
    return 0
  else
    echo "Expected update_issue_status to fail with missing arguments" >&2
    return 1
  fi
}

# テスト5: GraphQLエラー
test_graphql_error() {
  setup
  mock_gh_graphql_failure

  run_command update_issue_status "owner" "repo" "123"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub APIの呼び出しに失敗しました" || return 1
    return 0
  else
    echo "Expected update_issue_status to fail with GraphQL error" >&2
    return 1
  fi
}

# テストの実行
run_test_case "TODOからIN_PROGRESSへの更新" test_update_from_todo_to_in_progress
run_test_case "既にIN_PROGRESSの場合のスキップ" test_skip_already_in_progress
run_test_case "プロジェクトが関連付けられていない場合" test_no_project_associated
run_test_case "引数不足エラー" test_missing_arguments
run_test_case "GraphQLエラー" test_graphql_error

echo ""
echo "All Status Updater tests completed!"
