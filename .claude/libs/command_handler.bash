#!/usr/bin/env bash

# Command Handler
# Slash Commandのエントリーポイント

set -euo pipefail

# 依存ライブラリをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.claude/libs/url_parser.bash
source "${SCRIPT_DIR}/url_parser.bash"
# shellcheck source=.claude/libs/github_client.bash
source "${SCRIPT_DIR}/github_client.bash"
# shellcheck source=.claude/libs/status_updater.bash
source "${SCRIPT_DIR}/status_updater.bash"
# shellcheck source=.claude/libs/git_manager.bash
source "${SCRIPT_DIR}/git_manager.bash"

# 使用方法を表示
show_usage() {
  cat << EOF
使用方法:
  $0 <GitHub Issue URL> [options]

引数:
  GitHub Issue URL    GitHubのissue URL (例: https://github.com/owner/repo/issues/123)

オプション:
  --branch <name>     新しいブランチを作成してからステータスを更新
  -h, --help          このヘルプメッセージを表示

例:
  # 基本的な使用法
  $0 https://github.com/owner/repo/issues/123

  # ブランチ作成と同時
  $0 https://github.com/owner/repo/issues/123 --branch feature/add-login
EOF
}

# メインの処理
handle_update_issue_status() {
  local issue_url=""
  local branch_name=""
  local branch_mode=false

  # 引数を解析
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_usage
        return 0
        ;;
      --branch)
        if [[ -n "${2:-}" ]]; then
          branch_name="$2"
          branch_mode=true
          shift 2
        else
          echo "エラー: --branch オプションにはブランチ名が必要です。" >&2
          return 1
        fi
        ;;
      *)
        if [[ -z "${issue_url}" ]]; then
          issue_url="$1"
          shift
        else
          echo "エラー: 不明なオプション: $1" >&2
          show_usage >&2
          return 1
        fi
        ;;
    esac
  done

  # 必須引数チェック
  if [[ -z "${issue_url}" ]]; then
    echo "エラー: GitHub issue URLが必要です。" >&2
    show_usage >&2
    return 1
  fi

  # GitHub認証を確認
  if ! check_gh_auth; then
    return 1
  fi

  # ブランチモードの場合
  if [[ "${branch_mode}" == "true" ]]; then
    if [[ -z "${branch_name}" ]]; then
      echo "エラー: --branch オプションにはブランチ名が必要です。" >&2
      return 1
    fi
    create_branch_and_update_status "${branch_name}" "${issue_url}"
    return $?
  fi

  # 通常モード: issueステータスを直接更新
  # issue URLを解析
  local parse_result
  parse_result=$(parse_github_issue_url "${issue_url}")
  local parse_status=$?

  if [[ ${parse_status} -ne 0 ]]; then
    return 1
  fi

  local owner
  local repo
  local issue_number
  owner=$(echo "${parse_result}" | sed -n '1p')
  repo=$(echo "${parse_result}" | sed -n '2p')
  issue_number=$(echo "${parse_result}" | sed -n '3p')

  # ステータスを更新
  update_issue_status "${owner}" "${repo}" "${issue_number}"
  return $?
}

# スクリプトが直接実行された場合
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  handle_update_issue_status "$@"
fi
