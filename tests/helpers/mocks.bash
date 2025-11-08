#!/usr/bin/env bash

# モックヘルパー関数
# テスト時にGitHub CLIやGitコマンドをモックするための関数

# モックの状態を保存するディレクトリ
export MOCK_STATE_DIR

# モックの初期化
setup_mocks() {
  MOCK_STATE_DIR=$(mktemp -d)
  export PATH="${MOCK_STATE_DIR}/bin:${PATH}"
  mkdir -p "${MOCK_STATE_DIR}/bin"
}

# モックのクリーンアップ
teardown_mocks() {
  if [[ -n "${MOCK_STATE_DIR}" && -d "${MOCK_STATE_DIR}" ]]; then
    rm -rf "${MOCK_STATE_DIR}"
  fi
}

# ghコマンドのモック: 認証済み
mock_gh_auth_success() {
  cat > "${MOCK_STATE_DIR}/bin/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "✓ Logged in to github.com as testuser"
  exit 0
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# ghコマンドのモック: 未認証
mock_gh_auth_failure() {
  cat > "${MOCK_STATE_DIR}/bin/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "You are not logged into any GitHub hosts. Run gh auth login to authenticate."
  exit 1
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# ghコマンドのモック: issue情報取得成功
mock_gh_api_get_issue_success() {
  local owner="$1"
  local repo="$2"
  local issue_number="$3"

  cat > "${MOCK_STATE_DIR}/bin/gh" << EOF
#!/usr/bin/env bash
if [[ "\$1" == "api" && "\$2" == "repos/${owner}/${repo}/issues/${issue_number}" ]]; then
  echo '{
    "number": ${issue_number},
    "title": "Test Issue",
    "state": "open",
    "html_url": "https://github.com/${owner}/${repo}/issues/${issue_number}"
  }'
  exit 0
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# ghコマンドのモック: issue不存在
mock_gh_api_get_issue_not_found() {
  local owner="$1"
  local repo="$2"
  local issue_number="$3"

  cat > "${MOCK_STATE_DIR}/bin/gh" << EOF
#!/usr/bin/env bash
if [[ "\$1" == "api" && "\$2" == "repos/${owner}/${repo}/issues/${issue_number}" ]]; then
  echo '{"message": "Not Found"}' >&2
  exit 1
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# ghコマンドのモック: GraphQLクエリ成功
mock_gh_graphql_success() {
  local response_file="$1"

  cat > "${MOCK_STATE_DIR}/bin/gh" << EOF
#!/usr/bin/env bash
if [[ "\$1" == "api" && "\$2" == "graphql" ]]; then
  cat "${response_file}"
  exit 0
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# ghコマンドのモック: GraphQLクエリ失敗
mock_gh_graphql_failure() {
  cat > "${MOCK_STATE_DIR}/bin/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "api" && "$2" == "graphql" ]]; then
  echo '{"errors": [{"message": "GraphQL error"}]}' >&2
  exit 1
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/gh"
}

# gitコマンドのモック: ブランチ作成成功
mock_git_checkout_success() {
  cat > "${MOCK_STATE_DIR}/bin/git" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "checkout" && "$2" == "-b" ]]; then
  echo "Switched to a new branch '$3'"
  exit 0
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/git"
}

# gitコマンドのモック: ブランチ作成失敗（既存ブランチ）
mock_git_checkout_failure_exists() {
  cat > "${MOCK_STATE_DIR}/bin/git" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "checkout" && "$2" == "-b" ]]; then
  echo "fatal: A branch named '$3' already exists." >&2
  exit 128
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/git"
}

# gitコマンドのモック: コミット成功
mock_git_commit_success() {
  cat > "${MOCK_STATE_DIR}/bin/git" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "commit" ]]; then
  echo "[main abc1234] Test commit"
  echo " 1 file changed, 1 insertion(+)"
  exit 0
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/git"
}

# gitコマンドのモック: コミット失敗（変更なし）
mock_git_commit_failure_nothing_to_commit() {
  cat > "${MOCK_STATE_DIR}/bin/git" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "commit" ]]; then
  echo "nothing to commit, working tree clean" >&2
  exit 1
fi
EOF
  chmod +x "${MOCK_STATE_DIR}/bin/git"
}

# モックレスポンス用のJSONファイルを作成
create_mock_response_file() {
  local filename="$1"
  local content="$2"

  echo "${content}" > "${MOCK_STATE_DIR}/${filename}"
  echo "${MOCK_STATE_DIR}/${filename}"
}
