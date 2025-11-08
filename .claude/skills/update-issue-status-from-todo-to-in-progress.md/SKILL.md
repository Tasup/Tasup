---
name: update-issue-status-from-todo-to-in-progress
description: Update the status of a GitHub Issue from TODO to IN_PROGRESS using the `gh project item-edit` command.
---

# Update Issue Status from TODO to IN_PROGRESS

## Instructions

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Execute GitHub CLI Commands**: Follow the step-by-step commands in `gh-commands.md` to:
   - Get project information
   - Get project item ID
   - Get field information
   - Update issue status to "In progress"
   - Verify the update

3. **Handle Errors**: Ensure to handle potential errors, such as invalid URLs, non-existent issues, issues not linked to a project, missing authentication scopes, and network issues. Provide clear error messages for each scenario.

4. **Confirm Success**: After successfully updating the status, verify the update and confirm with a success message.

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- Refer to `gh-commands.md` for detailed command usage and examples.

Read @../gh-commands.md