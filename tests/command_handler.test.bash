#!/usr/bin/env bash

# Command Handler Tests
# コマンドハンドラーのテスト

set -euo pipefail

# テストヘルパーとモックをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/helpers/test_helper.bash
source "${SCRIPT_DIR}/helpers/test_helper.bash"
# shellcheck source=tests/helpers/mocks.bash
source "${SCRIPT_DIR}/helpers/mocks.bash"

# Command Handlerライブラリをロード
PROJECT_ROOT=$(get_project_root)
# shellcheck source=.claude/libs/command_handler.bash
source "${PROJECT_ROOT}/.claude/libs/command_handler.bash"

echo "========================================="
echo "  Command Handler Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
  mock_gh_auth_success
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: 基本的な使用法（オプションなし）
test_basic_usage() {
  setup

  # プロジェクト情報をモック（TODOステータス）
  local response_file
  response_file=$(create_mock_response_file "cmd_todo.json" '{
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
                          {"id": "in_progress_id", "name": "In Progress"}
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

  run_command handle_update_issue_status "https://github.com/owner/repo/issues/123"

  teardown

  # ステータス更新が実行されることを確認
  assert_contains "${output}" "ステータスを更新" || return 1
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected handle_update_issue_status to succeed" >&2
    return 1
  fi
}

# テスト2: ブランチ作成オプション
test_branch_option() {
  setup
  setup_temp_dir

  # 一時ディレクトリでgitリポジトリを初期化
  cd "${TEST_TEMP_DIR}"
  git init > /dev/null 2>&1
  git config user.email "test@example.com"
  git config user.name "Test User"
  echo "test" > README.md
  git add README.md
  git commit -m "Initial commit" > /dev/null 2>&1

  # プロジェクト情報をモック
  local response_file
  response_file=$(create_mock_response_file "cmd_branch.json" '{
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
                          {"id": "in_progress_id", "name": "In Progress"}
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

  run_command handle_update_issue_status "https://github.com/owner/repo/issues/456" --branch feature/test

  cd "${PROJECT_ROOT}"
  teardown_temp_dir
  teardown

  # ブランチ作成とステータス更新が実行されることを確認
  assert_contains "${output}" "ブランチ" || return 1
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected handle_update_issue_status to succeed with branch option" >&2
    return 1
  fi
}

# テスト3: ヘルプオプション
test_help_option() {
  run_command handle_update_issue_status --help

  # ヘルプメッセージが表示されることを確認
  assert_contains "${output}" "使用方法" || return 1
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected help option to succeed" >&2
    return 1
  fi
}

# テスト4: 必須引数欠如
test_missing_required_argument() {
  setup

  run_command handle_update_issue_status

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub issue URLが必要です" || return 1
    return 0
  else
    echo "Expected to fail with missing argument" >&2
    return 1
  fi
}

# テスト5: 無効なオプション
test_invalid_option() {
  setup

  run_command handle_update_issue_status "https://github.com/owner/repo/issues/123" --invalid

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "不明なオプション" || return 1
    return 0
  else
    echo "Expected to fail with invalid option" >&2
    return 1
  fi
}

# テスト6: --branchオプションにブランチ名がない
test_branch_option_without_name() {
  setup

  run_command handle_update_issue_status "https://github.com/owner/repo/issues/123" --branch

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "ブランチ名が必要です" || return 1
    return 0
  else
    echo "Expected to fail when --branch has no branch name" >&2
    return 1
  fi
}

# テストの実行
run_test_case "基本的な使用法（オプションなし）" test_basic_usage
run_test_case "ブランチ作成オプション" test_branch_option
run_test_case "ヘルプオプション" test_help_option
run_test_case "必須引数欠如" test_missing_required_argument
run_test_case "無効なオプション" test_invalid_option
run_test_case "--branchオプションにブランチ名がない" test_branch_option_without_name

echo ""
echo "All Command Handler tests completed!"
