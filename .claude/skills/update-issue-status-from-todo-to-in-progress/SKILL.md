---
name: update-issue-status
description: Update the status of a GitHub Issue to any available status using the `gh project item-edit` command. Allows interactive status selection via CLI.
supporting_files:
  - path: .claude/skills/gh-commands.md
    description: GitHub CLI commands reference for project status updates
---

# Update Issue Status

## Required Files
This skill requires the following supporting file:
- `.claude/skills/gh-commands.md`: Contains all GitHub CLI commands needed for project status updates

## Instructions
Provide clear, step-by-step guidance for Claude.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Get Project Information**: Refer to `.claude/skills/gh-commands.md` for the command to retrieve project information. Extract the first project's ID and number from the JSON output.

3. **Get Project Item ID**: Refer to `.claude/skills/gh-commands.md` for the command to retrieve project items. Find the item that matches the issue number and extract its ID and current status.

4. **Get Field Information**: Refer to `.claude/skills/gh-commands.md` for the command to retrieve project fields. Find the "Status" field ID and all available status options from the JSON output.

5. **Present Current Status and Ask User**: Display the current status of the issue to the user. Then use the AskUserQuestion tool to present all available status options (excluding the current status) and let the user select the desired new status. Format the question as follows:
   - Question: "issue #NUMBER を現在の「CURRENT_STATUS」からどのステータスに変更しますか？"
   - Header: "ステータス選択"
   - Options: List all available statuses except the current one (maximum 4 options, if more than 4 statuses exist, group logically or present the most common ones)

6. **Update Issue Status**: Refer to `.claude/skills/gh-commands.md` for the command to update the issue status. Replace the placeholders with the values obtained in previous steps and the user-selected status option ID.

7. **Handle Errors**: Ensure to handle potential errors, such as invalid URLs, non-existent issues, issues not linked to a project, missing authentication scopes, and network issues. Provide clear error messages for each scenario.

8. **Confirm Success**: Refer to `.claude/skills/gh-commands.md` for the command to verify the update. Confirm with a success message showing the old and new status.

## Command Reference
All required GitHub CLI commands are documented in `.claude/skills/gh-commands.md`. Refer to that file for:
- Getting project information
- Listing project items
- Retrieving field information
- Updating issue status
- Verifying updates

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- All command examples and usage patterns are maintained in `.claude/skills/gh-commands.md`


