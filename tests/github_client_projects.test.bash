#!/usr/bin/env bash

# GitHub API Client - Projects Tests
# プロジェクト情報取得機能のテスト

set -euo pipefail

# テストヘルパーとモックをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/helpers/test_helper.bash
source "${SCRIPT_DIR}/helpers/test_helper.bash"
# shellcheck source=tests/helpers/mocks.bash
source "${SCRIPT_DIR}/helpers/mocks.bash"

# GitHub API Clientライブラリをロード
PROJECT_ROOT=$(get_project_root)
# shellcheck source=.claude/libs/github_client.bash
source "${PROJECT_ROOT}/.claude/libs/github_client.bash"

echo "========================================="
echo "  GitHub API Client - Projects Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: 単一プロジェクト取得成功
test_get_single_project() {
  setup

  # 単一プロジェクトのレスポンスモック
  local response_file
  response_file=$(create_mock_response_file "projects_single.json" '{
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

  local result
  result=$(get_issue_projects "owner" "repo" "123")

  teardown

  # レスポンスに期待されるフィールドが含まれることを確認
  assert_contains "${result}" '"projectItems"' || return 1
  assert_contains "${result}" '"Test Project"' || return 1
  assert_contains "${result}" '"Status"' || return 1
  return 0
}

# テスト2: 複数プロジェクト取得成功
test_get_multiple_projects() {
  setup

  # 複数プロジェクトのレスポンスモック
  local response_file
  response_file=$(create_mock_response_file "projects_multiple.json" '{
    "data": {
      "repository": {
        "issue": {
          "projectItems": {
            "nodes": [
              {
                "id": "PVTI_1",
                "project": {
                  "id": "PVT_1",
                  "title": "Project 1"
                },
                "fieldValues": {
                  "nodes": [
                    {
                      "name": "Todo",
                      "field": {
                        "id": "PVTF_1",
                        "name": "Status",
                        "options": [
                          {"id": "todo_1", "name": "Todo"},
                          {"id": "in_progress_1", "name": "In Progress"}
                        ]
                      }
                    }
                  ]
                }
              },
              {
                "id": "PVTI_2",
                "project": {
                  "id": "PVT_2",
                  "title": "Project 2"
                },
                "fieldValues": {
                  "nodes": [
                    {
                      "name": "Backlog",
                      "field": {
                        "id": "PVTF_2",
                        "name": "Status",
                        "options": [
                          {"id": "backlog_2", "name": "Backlog"},
                          {"id": "active_2", "name": "Active"}
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

  local result
  result=$(get_issue_projects "owner" "repo" "456")

  teardown

  # 複数のプロジェクトが含まれることを確認
  assert_contains "${result}" '"Project 1"' || return 1
  assert_contains "${result}" '"Project 2"' || return 1
  return 0
}

# テスト3: プロジェクトが関連付けられていない場合
test_get_no_projects() {
  setup

  # プロジェクトなしのレスポンスモック
  local response_file
  response_file=$(create_mock_response_file "projects_none.json" '{
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

  run_command get_issue_projects "owner" "repo" "789"

  teardown

  # 警告メッセージが出力されることを確認
  assert_contains "${output}" "Issueはどのプロジェクトにも関連付けられていません" || return 1
  # 空のプロジェクト配列が返されることを確認
  assert_contains "${output}" '{"projects": []}' || return 1
  return 0
}

# テスト4: 引数不足エラー
test_get_projects_missing_args() {
  run_command get_issue_projects "owner" "repo"

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "owner、repo、issue_numberが必要です" || return 1
    return 0
  else
    echo "Expected get_issue_projects to fail with missing arguments" >&2
    return 1
  fi
}

# テスト5: GraphQLエラー
test_get_projects_graphql_error() {
  setup
  mock_gh_graphql_failure

  run_command get_issue_projects "owner" "repo" "123"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub APIの呼び出しに失敗しました" || return 1
    return 0
  else
    echo "Expected get_issue_projects to fail with GraphQL error" >&2
    return 1
  fi
}

# テストの実行
run_test_case "単一プロジェクト取得成功" test_get_single_project
run_test_case "複数プロジェクト取得成功" test_get_multiple_projects
run_test_case "プロジェクトが関連付けられていない場合" test_get_no_projects
run_test_case "引数不足エラー" test_get_projects_missing_args
run_test_case "GraphQLエラー" test_get_projects_graphql_error

echo ""
echo "All GitHub API Client Projects tests completed!"
