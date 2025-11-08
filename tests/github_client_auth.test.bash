#!/usr/bin/env bash

# GitHub API Client - Auth Tests
# GitHub認証確認機能のテスト

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
echo "  GitHub API Client - Auth Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: 認証済みの場合
test_auth_success() {
  setup
  mock_gh_auth_success

  if check_gh_auth; then
    teardown
    return 0
  else
    teardown
    echo "Expected check_gh_auth to succeed" >&2
    return 1
  fi
}

# テスト2: 未認証の場合
test_auth_failure() {
  setup
  mock_gh_auth_failure

  run_command check_gh_auth

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub認証が必要です" || return 1
    assert_contains "${output}" "gh auth login" || return 1
    return 0
  else
    echo "Expected check_gh_auth to fail" >&2
    echo "DEBUG: status was ${status}, output was: ${output}" >&2
    return 1
  fi
}

# テスト3: ghコマンドが存在しない場合
test_gh_command_not_found() {
  setup

  # ghコマンドをモックせず、PATHからも除外
  export PATH="/usr/bin:/bin"

  run_command check_gh_auth

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub CLI (gh) がインストールされていません" || return 1
    return 0
  else
    echo "Expected check_gh_auth to fail when gh is not installed" >&2
    return 1
  fi
}

# テストの実行
run_test_case "認証済みの場合" test_auth_success
run_test_case "未認証の場合" test_auth_failure
run_test_case "ghコマンドが存在しない場合" test_gh_command_not_found

echo ""
echo "All GitHub API Client Auth tests completed!"
