#!/usr/bin/env bash

# GitHub API Client - GraphQL Tests
# GraphQL実行機能のテスト

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
echo "  GitHub API Client - GraphQL Tests"
echo "========================================="

# テスト前のセットアップ
setup() {
  setup_mocks
}

# テスト後のクリーンアップ
teardown() {
  teardown_mocks
}

# テスト1: GraphQLクエリ実行成功
test_execute_graphql_success() {
  setup

  # 成功レスポンスのモックファイルを作成
  local response_file
  response_file=$(create_mock_response_file "graphql_success.json" '{
    "data": {
      "viewer": {
        "login": "testuser"
      }
    }
  }')

  mock_gh_graphql_success "${response_file}"

  local query='{ viewer { login } }'
  local result
  result=$(execute_graphql "${query}")

  teardown

  # レスポンスにdataフィールドが含まれることを確認
  assert_contains "${result}" '"data"' || return 1
  assert_contains "${result}" '"viewer"' || return 1
  return 0
}

# テスト2: GraphQLクエリ実行失敗（APIエラー）
test_execute_graphql_api_error() {
  setup
  mock_gh_graphql_failure

  local query='{ invalid query }'
  run_command execute_graphql "${query}"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub APIの呼び出しに失敗しました" || return 1
    return 0
  else
    echo "Expected execute_graphql to fail with API error" >&2
    return 1
  fi
}

# テスト3: GraphQLレスポンスにエラーが含まれる場合
test_execute_graphql_response_error() {
  setup

  # エラーを含むレスポンスのモックファイルを作成
  local response_file
  response_file=$(create_mock_response_file "graphql_error.json" '{
    "errors": [
      {
        "message": "Field '\''invalid'\'' doesn'\''t exist on type '\''Query'\''"
      }
    ]
  }')

  mock_gh_graphql_success "${response_file}"

  local query='{ invalid }'
  run_command execute_graphql "${query}"

  teardown

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GitHub APIの呼び出しに失敗しました" || return 1
    return 0
  else
    echo "Expected execute_graphql to fail with response error" >&2
    return 1
  fi
}

# テスト4: 空のクエリ
test_execute_graphql_empty_query() {
  run_command execute_graphql ""

  if [[ ${status} -ne 0 ]]; then
    assert_contains "${output}" "GraphQLクエリが必要です" || return 1
    return 0
  else
    echo "Expected execute_graphql to fail with empty query" >&2
    return 1
  fi
}

# テスト5: 複雑なGraphQLクエリ
test_execute_graphql_complex_query() {
  setup

  # 複雑なレスポンスのモックファイルを作成
  local response_file
  response_file=$(create_mock_response_file "graphql_complex.json" '{
    "data": {
      "repository": {
        "issue": {
          "number": 123,
          "title": "Test Issue",
          "projectItems": {
            "nodes": [
              {
                "project": {
                  "title": "Project 1"
                }
              }
            ]
          }
        }
      }
    }
  }')

  mock_gh_graphql_success "${response_file}"

  local query='query { repository(owner: "owner", name: "repo") { issue(number: 123) { number title } } }'
  local result
  result=$(execute_graphql "${query}")

  teardown

  # レスポンスに期待されるフィールドが含まれることを確認
  assert_contains "${result}" '"repository"' || return 1
  assert_contains "${result}" '"issue"' || return 1
  assert_contains "${result}" '"number": 123' || return 1
  return 0
}

# テストの実行
run_test_case "GraphQLクエリ実行成功" test_execute_graphql_success
run_test_case "GraphQLクエリ実行失敗（APIエラー）" test_execute_graphql_api_error
run_test_case "GraphQLレスポンスにエラーが含まれる場合" test_execute_graphql_response_error
run_test_case "空のクエリ" test_execute_graphql_empty_query
run_test_case "複雑なGraphQLクエリ" test_execute_graphql_complex_query

echo ""
echo "All GitHub API Client GraphQL tests completed!"
