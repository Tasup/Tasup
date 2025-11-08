#!/usr/bin/env bash

# シンプルなBashテストランナー
# 各テストファイルを実行し、結果を集計する

set -euo pipefail

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# テスト統計
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# テスト結果の表示
print_test_result() {
  local test_name="$1"
  local status="$2"
  local message="${3:-}"

  if [[ "${status}" == "PASS" ]]; then
    echo -e "${GREEN}✓${NC} ${test_name}"
    ((PASSED_TESTS++))
  else
    echo -e "${RED}✗${NC} ${test_name}"
    if [[ -n "${message}" ]]; then
      echo -e "  ${RED}${message}${NC}"
    fi
    ((FAILED_TESTS++))
  fi
  ((TOTAL_TESTS++))
}

# テストの実行
run_test() {
  local test_file="$1"
  echo -e "\n${YELLOW}Running tests in ${test_file}${NC}"

  if [[ -f "${test_file}" ]]; then
    bash "${test_file}"
  else
    echo -e "${RED}Test file not found: ${test_file}${NC}"
    return 1
  fi
}

# 使用方法
usage() {
  cat << EOF
Usage: $0 [options] [test_file]

Options:
  -h, --help     このヘルプメッセージを表示
  -v, --verbose  詳細な出力

Arguments:
  test_file      実行するテストファイル（指定しない場合は全テストを実行）
EOF
}

# メイン処理
main() {
  local test_pattern="${1:-}"

  echo "========================================="
  echo "  GitHub Issue Status Auto Update Tests"
  echo "========================================="

  if [[ -n "${test_pattern}" ]]; then
    # 特定のテストファイルを実行
    if [[ -f "${test_pattern}" ]]; then
      run_test "${test_pattern}"
    else
      echo -e "${RED}Error: Test file not found: ${test_pattern}${NC}"
      exit 1
    fi
  else
    # 全テストを実行
    local test_files
    test_files=$(find "${PROJECT_ROOT}/tests" -name "*.test.bash" -type f | sort)

    if [[ -z "${test_files}" ]]; then
      echo -e "${YELLOW}No test files found${NC}"
      exit 0
    fi

    for test_file in ${test_files}; do
      run_test "${test_file}"
    done
  fi

  # 結果サマリー
  echo ""
  echo "========================================="
  echo "  Test Summary"
  echo "========================================="
  echo "Total:  ${TOTAL_TESTS}"
  echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"

  if [[ ${FAILED_TESTS} -gt 0 ]]; then
    echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"
    exit 1
  else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  fi
}

# コマンドライン引数の解析
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  *)
    main "$@"
    ;;
esac
