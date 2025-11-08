#!/usr/bin/env bash

# GitHub API Client
# GitHub CLIを使用してGitHub APIを操作する

# GitHub CLIの認証状態を確認する
#
# Returns:
#   成功時: 0
#   失敗時: エラーメッセージを標準エラー出力に出力し、1を返す
#
# Example:
#   if check_gh_auth; then
#     echo "認証済み"
#   fi
check_gh_auth() {
  # gh auth statusコマンドで認証状態を確認
  if ! command -v gh &> /dev/null; then
    echo "エラー: GitHub CLI (gh) がインストールされていません。" >&2
    echo "インストール方法: https://cli.github.com/" >&2
    return 1
  fi

  # 認証状態の確認（出力は破棄するが、終了コードは確認）
  local auth_output
  auth_output=$(gh auth status 2>&1)
  local auth_status=$?

  if [[ ${auth_status} -eq 0 ]]; then
    return 0
  else
    echo "エラー: GitHub認証が必要です。\`gh auth login\`を実行してください。" >&2
    return 1
  fi
}

# Issue情報を取得する
#
# Args:
#   $1: owner (リポジトリオーナー)
#   $2: repo (リポジトリ名)
#   $3: issue_number (Issue番号)
#
# Returns:
#   成功時: issue情報をJSONで出力し、0を返す
#   失敗時: エラーメッセージを標準エラー出力に出力し、非ゼロを返す
#
# Example:
#   issue_info=$(get_issue_info "owner" "repo" "123")
get_issue_info() {
  local owner="${1:-}"
  local repo="${2:-}"
  local issue_number="${3:-}"

  # 引数チェック
  if [[ -z "${owner}" || -z "${repo}" || -z "${issue_number}" ]]; then
    echo "エラー: owner、repo、issue_numberが必要です。" >&2
    return 1
  fi

  # GitHub API経由でissue情報を取得
  local api_response
  local api_status

  api_response=$(gh api "repos/${owner}/${repo}/issues/${issue_number}" 2>&1)
  api_status=$?

  if [[ ${api_status} -eq 0 ]]; then
    echo "${api_response}"
    return 0
  else
    # エラーメッセージを解析
    if echo "${api_response}" | grep -qF "Not Found"; then
      echo "エラー: Issue #${issue_number} が ${owner}/${repo} に存在しません。" >&2
    elif echo "${api_response}" | grep -qF "Forbidden" || echo "${api_response}" | grep -qF "403"; then
      echo "エラー: リポジトリまたはプロジェクトへのアクセス権限がありません。" >&2
    else
      echo "エラー: Issue情報の取得に失敗しました: ${api_response}" >&2
    fi
    return 1
  fi
}

# GraphQLクエリを実行する
#
# Args:
#   $1: GraphQLクエリ文字列
#
# Returns:
#   成功時: GraphQLレスポンスをJSONで出力し、0を返す
#   失敗時: エラーメッセージを標準エラー出力に出力し、非ゼロを返す
#
# Example:
#   query='{ viewer { login } }'
#   result=$(execute_graphql "${query}")
execute_graphql() {
  local query="${1:-}"

  # 引数チェック
  if [[ -z "${query}" ]]; then
    echo "エラー: GraphQLクエリが必要です。" >&2
    return 1
  fi

  # GraphQL APIを実行
  local api_response
  local api_status

  api_response=$(gh api graphql -f query="${query}" 2>&1)
  api_status=$?

  if [[ ${api_status} -eq 0 ]]; then
    # レスポンスにエラーが含まれていないか確認
    if echo "${api_response}" | grep -qF '"errors"'; then
      echo "エラー: GitHub APIの呼び出しに失敗しました: ${api_response}" >&2
      return 1
    fi
    echo "${api_response}"
    return 0
  else
    # APIエラー
    echo "エラー: GitHub APIの呼び出しに失敗しました: ${api_response}" >&2
    return 1
  fi
}

# Issueが関連付けられているプロジェクト情報を取得する
#
# Args:
#   $1: owner (リポジトリオーナー)
#   $2: repo (リポジトリ名)
#   $3: issue_number (Issue番号)
#
# Returns:
#   成功時: プロジェクト情報をJSONで出力し、0を返す
#   失敗時: エラーメッセージを標準エラー出力に出力し、非ゼロを返す
#
# Example:
#   projects=$(get_issue_projects "owner" "repo" "123")
get_issue_projects() {
  local owner="${1:-}"
  local repo="${2:-}"
  local issue_number="${3:-}"

  # 引数チェック
  if [[ -z "${owner}" || -z "${repo}" || -z "${issue_number}" ]]; then
    echo "エラー: owner、repo、issue_numberが必要です。" >&2
    return 1
  fi

  # GraphQLクエリを構築
  local query
  read -r -d '' query << EOF || true
query {
  repository(owner: "${owner}", name: "${repo}") {
    issue(number: ${issue_number}) {
      projectItems(first: 10) {
        nodes {
          id
          project {
            id
            title
          }
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
                field {
                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    options {
                      id
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
EOF

  # GraphQLクエリを実行
  local result
  result=$(execute_graphql "${query}")
  local status=$?

  if [[ ${status} -ne 0 ]]; then
    return 1
  fi

  # プロジェクトが存在するか確認
  if echo "${result}" | grep -qF '"nodes": []'; then
    echo "警告: Issueはどのプロジェクトにも関連付けられていません。" >&2
    echo '{"projects": []}'
    return 0
  fi

  echo "${result}"
  return 0
}
