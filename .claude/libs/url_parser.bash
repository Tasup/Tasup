#!/usr/bin/env bash

# GitHub Issue URL Parser
# GitHub issue URLを解析してowner、repo、issueNumberを抽出する

# GitHub issue URLを解析する
#
# Args:
#   $1: GitHub issue URL (例: https://github.com/owner/repo/issues/123)
#
# Returns:
#   成功時: owner、repo、issueNumberを改行区切りで出力
#   失敗時: エラーメッセージを標準エラー出力に出力し、非ゼロで終了
#
# Example:
#   result=$(parse_github_issue_url "https://github.com/owner/repo/issues/123")
#   owner=$(echo "$result" | sed -n '1p')
#   repo=$(echo "$result" | sed -n '2p')
#   issue_number=$(echo "$result" | sed -n '3p')
parse_github_issue_url() {
  local url="${1:-}"

  # URLが空の場合
  if [[ -z "${url}" ]]; then
    echo "エラー: URLが指定されていません。" >&2
    return 1
  fi

  # GitHub issue URLの正規表現パターン
  # https://github.com/owner/repo/issues/123 の形式
  local pattern='^https?://github\.com/([^/]+)/([^/]+)/issues/([0-9]+)/?$'

  if [[ "${url}" =~ ${pattern} ]]; then
    local owner="${BASH_REMATCH[1]}"
    local repo="${BASH_REMATCH[2]}"
    local issue_number="${BASH_REMATCH[3]}"

    # 出力
    echo "${owner}"
    echo "${repo}"
    echo "${issue_number}"
    return 0
  else
    echo "エラー: 無効なGitHub issue URLです。正しい形式: https://github.com/owner/repo/issues/123" >&2
    return 1
  fi
}

# URL検証のみ実行（解析せずに検証だけ行う）
#
# Args:
#   $1: GitHub issue URL
#
# Returns:
#   成功時: 0
#   失敗時: 1
validate_github_issue_url() {
  local url="${1:-}"
  local pattern='^https?://github\.com/([^/]+)/([^/]+)/issues/([0-9]+)/?$'

  if [[ "${url}" =~ ${pattern} ]]; then
    return 0
  else
    return 1
  fi
}
