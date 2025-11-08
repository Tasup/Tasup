#!/usr/bin/env bash

# URL Parser Tests
# URL解析ライブラリのテスト

set -euo pipefail

# テストヘルパーをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/helpers/test_helper.bash
source "${SCRIPT_DIR}/helpers/test_helper.bash"

# URL Parserライブラリをロード
PROJECT_ROOT=$(get_project_root)
# shellcheck source=.claude/libs/url_parser.bash
source "${PROJECT_ROOT}/.claude/libs/url_parser.bash"

echo "========================================="
echo "  URL Parser Tests"
echo "========================================="

# テスト1: 有効なURL形式の解析
test_valid_url_parsing() {
  local url="https://github.com/owner/repo/issues/123"
  local result
  result=$(parse_github_issue_url "${url}")

  local owner
  local repo
  local issue_number
  owner=$(echo "$result" | sed -n '1p')
  repo=$(echo "$result" | sed -n '2p')
  issue_number=$(echo "$result" | sed -n '3p')

  assert_equal "owner" "${owner}" "Owner should be 'owner'" || return 1
  assert_equal "repo" "${repo}" "Repo should be 'repo'" || return 1
  assert_equal "123" "${issue_number}" "Issue number should be '123'" || return 1
}

# テスト2: HTTPプロトコルのURL解析
test_http_protocol() {
  local url="http://github.com/test-owner/test-repo/issues/456"
  local result
  result=$(parse_github_issue_url "${url}")

  local owner
  owner=$(echo "$result" | sed -n '1p')

  assert_equal "test-owner" "${owner}" "Owner should be 'test-owner'" || return 1
}

# テスト3: 末尾スラッシュ付きURL解析
test_trailing_slash() {
  local url="https://github.com/owner/repo/issues/789/"
  local result
  result=$(parse_github_issue_url "${url}")

  local issue_number
  issue_number=$(echo "$result" | sed -n '3p')

  assert_equal "789" "${issue_number}" "Issue number should be '789'" || return 1
}

# テスト4: 無効なURL - プロトコルなし
test_invalid_url_no_protocol() {
  local url="github.com/owner/repo/issues/123"

  run_command parse_github_issue_url "${url}"
  assert_failure || return 1
  assert_contains "${output}" "無効なGitHub issue URL" || return 1
}

# テスト5: 無効なURL - issue番号なし
test_invalid_url_no_issue_number() {
  local url="https://github.com/owner/repo/issues/"

  run_command parse_github_issue_url "${url}"
  assert_failure || return 1
  assert_contains "${output}" "無効なGitHub issue URL" || return 1
}

# テスト6: 無効なURL - GitHub以外のドメイン
test_invalid_url_non_github_domain() {
  local url="https://gitlab.com/owner/repo/issues/123"

  run_command parse_github_issue_url "${url}"
  assert_failure || return 1
  assert_contains "${output}" "無効なGitHub issue URL" || return 1
}

# テスト7: 無効なURL - pullリクエスト
test_invalid_url_pull_request() {
  local url="https://github.com/owner/repo/pull/123"

  run_command parse_github_issue_url "${url}"
  assert_failure || return 1
  assert_contains "${output}" "無効なGitHub issue URL" || return 1
}

# テスト8: 無効なURL - 空文字列
test_invalid_url_empty_string() {
  local url=""

  run_command parse_github_issue_url "${url}"
  assert_failure || return 1
  assert_contains "${output}" "URLが指定されていません" || return 1
}

# テスト9: URL検証関数 - 有効なURL
test_validate_valid_url() {
  local url="https://github.com/owner/repo/issues/123"

  if validate_github_issue_url "${url}"; then
    return 0
  else
    echo "Expected validation to succeed" >&2
    return 1
  fi
}

# テスト10: URL検証関数 - 無効なURL
test_validate_invalid_url() {
  local url="https://github.com/owner/repo/pull/123"

  if validate_github_issue_url "${url}"; then
    echo "Expected validation to fail" >&2
    return 1
  else
    return 0
  fi
}

# テストの実行
run_test_case "有効なURL形式の解析" test_valid_url_parsing
run_test_case "HTTPプロトコルのURL解析" test_http_protocol
run_test_case "末尾スラッシュ付きURL解析" test_trailing_slash
run_test_case "無効なURL - プロトコルなし" test_invalid_url_no_protocol
run_test_case "無効なURL - issue番号なし" test_invalid_url_no_issue_number
run_test_case "無効なURL - GitHub以外のドメイン" test_invalid_url_non_github_domain
run_test_case "無効なURL - pullリクエスト" test_invalid_url_pull_request
run_test_case "無効なURL - 空文字列" test_invalid_url_empty_string
run_test_case "URL検証関数 - 有効なURL" test_validate_valid_url
run_test_case "URL検証関数 - 無効なURL" test_validate_invalid_url

echo ""
echo "All URL Parser tests completed!"
