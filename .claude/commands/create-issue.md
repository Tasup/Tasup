# Create GitHub Issue

You are creating a new GitHub issue for this repository. Follow these steps:

## Step 1: Gather Information

Ask the user for the following information:

1. **Issue Title**: Ask "Issueのタイトルは何ですか？"
2. **Tasks**: Ask "どのようなタスクを実行したいですか？（1行に1つずつタスクを記載してください）"

## Step 2: Format the Issue

Once you have the information:

- Use the title as-is for the issue title
- Format the tasks as a checklist in the issue body using the following format:

```markdown
# タスク

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
```

## Step 3: Show Preview

Display a preview of the issue to the user:

```
Title: [????]

Body:
## タスク

- [ ] Task 1
- [ ] Task 2
```

Ask the user: "この内容で問題ありませんか？（y/ok で作成、またはフィードバックで修正）"

## Step 4: Create the Issue

If the user responds with "y" or "ok":

1. Use `gh issue create` command to create the issue
2. Display the created issue URL to the user
3. Display the following message to guide the user to the next step:

```
次のカスタムコマンドを実行してください
/implement-issue {作成したURL}
```

Replace `{作成したURL}` with the actual issue URL that was created.

If the user provides feedback, incorporate their changes and show the preview again.

## Important Notes

- Use the `gh issue create --title "..." --body "..."` command
- Pass the body using a HEREDOC for proper formatting
- After creating the issue, show the issue number and URL to the user
