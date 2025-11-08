#!/usr/bin/env bash

# GitHub API Client - Issue Tests
# Issue情報取得機能のテスト

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
echo "  GitHub API Client - Issue Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: Issue情報取得成功
test_get_issue_success() {
  setup
  mock_gh_api_get_issue_success "owner" "repo" "123"

  local result
  result=$(get_issue_info "owner" "repo" "123")

  teardown

  # JSONレスポンスが返されることを確認
  assert_contains "${result}" '"number": 123' || return 1
  assert_contains "${result}" '"title": "Test Issue"' || return 1
  return 0
}

# テスト2: Issue不存在エラー
test_get_issue_not_found() {
  setup
  mock_gh_api_get_issue_not_found "owner" "repo" "999"

  run_command get_issue_info "owner" "repo" "999"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "Issue #999 が owner/repo に存在しません" || return 1
    return 0
  else
    echo "Expected get_issue_info to fail for non-existent issue" >&2
    return 1
  fi
}

# テスト3: 引数不足エラー
test_get_issue_missing_args() {
  run_command get_issue_info "owner" "repo"

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "owner、repo、issue_numberが必要です" || return 1
    return 0
  else
    echo "Expected get_issue_info to fail with missing arguments" >&2
    return 1
  fi
}

# テスト4: 空文字列の引数
test_get_issue_empty_args() {
  run_command get_issue_info "" "" ""

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "owner、repo、issue_numberが必要です" || return 1
    return 0
  else
    echo "Expected get_issue_info to fail with empty arguments" >&2
    return 1
  fi
}

# テスト5: 権限エラー（Forbidden）
test_get_issue_forbidden() {
  setup

  # 権限エラーをモック
  cat > "${MOCK_STATE_DIR}/bin/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "api" ]]; then
  echo '{"message": "Forbidden"}' >&2
  exit 1
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"

  run_command get_issue_info "private-owner" "private-repo" "1"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "リポジトリまたはプロジェクトへのアクセス権限がありません" || return 1
    return 0
  else
    echo "Expected get_issue_info to fail with permission error" >&2
    return 1
  fi
}

# テストの実行
run_test_case "Issue情報取得成功" test_get_issue_success
run_test_case "Issue不存在エラー" test_get_issue_not_found
run_test_case "引数不足エラー" test_get_issue_missing_args
run_test_case "空文字列の引数" test_get_issue_empty_args
run_test_case "権限エラー（Forbidden）" test_get_issue_forbidden

echo ""
echo "All GitHub API Client Issue tests completed!"
