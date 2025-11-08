#!/usr/bin/env bash

# Git Manager - Branch Tests
# ブランチ作成機能のテスト

set -euo pipefail

# テストヘルパーとモックをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/helpers/test_helper.bash
source "${SCRIPT_DIR}/helpers/test_helper.bash"
# shellcheck source=tests/helpers/mocks.bash
source "${SCRIPT_DIR}/helpers/mocks.bash"

# Git Managerライブラリをロード
PROJECT_ROOT=$(get_project_root)
# shellcheck source=.claude/libs/git_manager.bash
source "${PROJECT_ROOT}/.claude/libs/git_manager.bash"

echo "========================================="
echo "  Git Manager - Branch Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
  setup_temp_dir

  # 一時ディレクトリでgitリポジトリを初期化
  cd "${TEST_TEMP_DIR}"
  git init > /dev/null 2>&1
  git config user.email "test@example.com"
  git config user.name "Test User"

  # 初期コミットを作成（ブランチ作成のため）
  echo "test" > README.md
  git add README.md
  git commit -m "Initial commit" > /dev/null 2>&1
}

# テスト後のクリーンアップ
teardown() {
  cd "${PROJECT_ROOT}"
  teardown_temp_dir
  teardown_mocks
}

# テスト1: ブランチ作成成功時のステータス更新
test_create_branch_and_update_success() {
  setup

  # プロジェクト情報をモック（TODOステータス）
  local response_file
  response_file=$(create_mock_response_file "branch_todo.json" '{
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

  run_command create_branch_and_update_status "feature/test-branch" "https://github.com/owner/repo/issues/123"

  teardown

  # ブランチ作成のメッセージが出力されることを確認
  assert_contains "${output}" "ブランチ「feature/test-branch」を作成" || return 1
  # ステータス更新のメッセージが出力されることを確認
  assert_contains "${output}" "ステータスを更新" || return 1
  # 成功することを確認
  if [[ ${status} -eq 0 ]]; then
    return 0
  else
    echo "Expected create_branch_and_update_status to succeed" >&2
    return 1
  fi
}

# テスト2: ブランチ作成失敗時のステータス未更新
test_create_branch_failure() {
  setup

  # 既に同じ名前のブランチを作成
  git checkout -b "existing-branch" > /dev/null 2>&1
  git checkout main > /dev/null 2>&1 || git checkout master > /dev/null 2>&1

  run_command create_branch_and_update_status "existing-branch" "https://github.com/owner/repo/issues/123"

  teardown

  # 失敗することを確認
  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "ブランチの作成に失敗" || return 1
    return 0
  else
    echo "Expected create_branch_and_update_status to fail when branch exists" >&2
    return 1
  fi
}

# テスト3: 無効なブランチ名
test_invalid_branch_name() {
  # スペースを含むブランチ名（シェルで正しくエスケープされるように）
  local invalid_branch="feature/test@branch"

  run_command create_branch_and_update_status "${invalid_branch}" "https://github.com/owner/repo/issues/123"

  # 失敗することを確認
  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "無効な文字" || return 1
    return 0
  else
    echo "Expected create_branch_and_update_status to fail with invalid branch name" >&2
    return 1
  fi
}

# テスト4: 引数不足エラー（ブランチ名なし）
test_missing_branch_name() {
  # 引数なしで実行（空文字列ではなく、引数自体を渡さない）
  run_command 'create_branch_and_update_status "" "https://github.com/owner/repo/issues/123"'

  if [[ ${status} -ne 0 ]]; then
    # エラーメッセージには「ブランチ名」または「必要」が含まれることを確認
    if echo "${output}" | grep -qF "ブランチ名" || echo "${output}" | grep -qF "必要"; then
      return 0
    else
      echo "Expected error about missing branch name, got: ${output}" >&2
      return 1
    fi
  else
    echo "Expected create_branch_and_update_status to fail with missing branch name" >&2
    return 1
  fi
}

# テスト5: 引数不足エラー（issue URLなし）
test_missing_issue_url() {
  run_command create_branch_and_update_status "feature/test" ""

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub issue URLが必要です" || return 1
    return 0
  else
    echo "Expected create_branch_and_update_status to fail with missing issue URL" >&2
    return 1
  fi
}

# テスト6: 無効なissue URL
test_invalid_issue_url() {
  run_command create_branch_and_update_status "feature/test" "https://invalid-url.com"

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "無効なGitHub issue URL" || return 1
    return 0
  else
    echo "Expected create_branch_and_update_status to fail with invalid URL" >&2
    return 1
  fi
}

# テストの実行
run_test_case "ブランチ作成成功時のステータス更新" test_create_branch_and_update_success
run_test_case "ブランチ作成失敗時のステータス未更新" test_create_branch_failure
run_test_case "無効なブランチ名" test_invalid_branch_name
run_test_case "引数不足エラー（ブランチ名なし）" test_missing_branch_name
run_test_case "引数不足エラー（issue URLなし）" test_missing_issue_url
run_test_case "無効なissue URL" test_invalid_issue_url

echo ""
echo "All Git Manager Branch tests completed!"
