#!/usr/bin/env bash

# テストヘルパー関数
# Bashテストで共通して使用する関数を定義

# プロジェクトのルートディレクトリを取得
get_project_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

# ライブラリをロード
load_lib() {
  local lib_name="$1"
  local project_root
  project_root=$(get_project_root)

  if [[ -f "${project_root}/.claude/libs/${lib_name}.bash" ]]; then
    # shellcheck source=/dev/null
    source "${project_root}/.claude/libs/${lib_name}.bash"
  else
    echo "Error: Library ${lib_name} not found" >&2
    return 1
  fi
}

# テスト用の一時ディレクトリを作成
setup_temp_dir() {
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)
}

# テスト用の一時ディレクトリを削除
teardown_temp_dir() {
  if [[ -n "${TEST_TEMP_DIR}" && -d "${TEST_TEMP_DIR}" ]]; then
    rm -rf "${TEST_TEMP_DIR}"
  fi
}

# アサーション: 文字列が等しい
assert_equal() {
  local expected="$1"
  local actual="$2"
  local message="${3:-Expected '${expected}', got '${actual}'}"

  if [[ "${expected}" != "${actual}" ]]; then
    echo "${message}" >&2
    return 1
  fi
}

# アサーション: 文字列が含まれる
assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-Expected to contain '${needle}', got '${haystack}'}"

  # grepを使用して部分一致を確認（改行を含む文字列にも対応）
  if echo "${haystack}" | grep -qF "${needle}"; then
    return 0
  else
    echo "${message}" >&2
    return 1
  fi
}

# アサーション: コマンドが成功する
assert_success() {
  if [[ "${status}" -ne 0 ]]; then
    echo "Expected success (exit code 0), got ${status}" >&2
    echo "Output: ${output}" >&2
    return 1
  fi
}

# アサーション: コマンドが失敗する
assert_failure() {
  if [[ "${status}" -eq 0 ]]; then
    echo "Expected failure (non-zero exit code), got ${status}" >&2
    echo "Output: ${output}" >&2
    return 1
  fi
}

# テストケースの実行
# Usage: run_test "test name" test_function
run_test_case() {
  local test_name="$1"
  local test_func="$2"

  echo -n "  Testing: ${test_name} ... "

  if ${test_func}; then
    echo -e "\033[0;32mPASS\033[0m"
    return 0
  else
    echo -e "\033[0;31mFAIL\033[0m"
    return 1
  fi
}

# コマンドの実行結果を変数に格納
# Usage: run_command command args...
run_command() {
  output=$(eval "$*" 2>&1) && status=0 || status=$?
  export output status
}
