#!/usr/bin/env bash

# Git Manager
# Gitブランチ・コミット操作とissueステータス更新を統合

# 依存ライブラリをロード
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.claude/libs/url_parser.bash
source "${SCRIPT_DIR}/url_parser.bash"
# shellcheck source=.claude/libs/status_updater.bash
source "${SCRIPT_DIR}/status_updater.bash"

# ブランチを作成し、issueステータスを更新する
#
# Args:
#   $1: branch_name (作成するブランチ名)
#   $2: issue_url (GitHub issue URL)
#
# Returns:
#   成功時: 0
#   失敗時: 非ゼロ
#
# Example:
#   create_branch_and_update_status "feature/add-login" "https://github.com/owner/repo/issues/123"
create_branch_and_update_status() {
  local branch_name="${1:-}"
  local issue_url="${2:-}"

  # 引数チェック
  if [[ -z "${branch_name}" ]]; then
    echo "エラー: ブランチ名が必要です。" >&2
    return 1
  fi

  if [[ -z "${issue_url}" ]]; then
    echo "エラー: GitHub issue URLが必要です。" >&2
    return 1
  fi

  # ブランチ名の検証（基本的なチェック）
  if [[ ! "${branch_name}" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
    echo "エラー: ブランチ名に無効な文字が含まれています。使用可能な文字: a-z, A-Z, 0-9, /, _, -" >&2
    return 1
  fi

  # issue URLを解析
  local parse_result
  parse_result=$(parse_github_issue_url "${issue_url}")
  local parse_status=$?

  if [[ ${parse_status} -ne 0 ]]; then
    # エラーメッセージは既にparse_github_issue_urlから出力されている
    return 1
  fi

  local owner
  local repo
  local issue_number
  owner=$(echo "${parse_result}" | sed -n '1p')
  repo=$(echo "${parse_result}" | sed -n '2p')
  issue_number=$(echo "${parse_result}" | sed -n '3p')

  # ブランチを作成
  echo "情報: ブランチ「${branch_name}」を作成しています..."

  if git checkout -b "${branch_name}" 2>&1; then
    echo "成功: ブランチ「${branch_name}」を作成しました。"
  else
    local git_status=$?
    echo "エラー: ブランチの作成に失敗しました。" >&2
    return ${git_status}
  fi

  # ブランチ作成成功後、issueステータスを更新
  echo "情報: Issue #${issue_number} のステータスを更新しています..."

  if update_issue_status "${owner}" "${repo}" "${issue_number}"; then
    return 0
  else
    echo "警告: ブランチは作成されましたが、issueステータスの更新に失敗しました。" >&2
    return 1
  fi
}
