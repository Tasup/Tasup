---
name: update-issue-status-from-todo-to-in-progress
description: Update the status of a GitHub Issue from TODO to IN_PROGRESS using the `gh project item-edit` command.
---

# Update Issue Status from TODO to IN_PROGRESS

## Instructions
Provide clear, step-by-step guidance for Claude.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Get Project Information**: Use the command `gh project list --owner OWNER --format json` to retrieve the list of projects. Extract the first project's ID and number from the JSON output.

3. **Get Project Item ID**: Use the command `gh project item-list PROJECT_NUMBER --owner OWNER --format json --limit 100` to retrieve all project items. Find the item that matches the issue number and extract its ID.

4. **Get Field Information**: Use the command `gh project field-list PROJECT_NUMBER --owner OWNER --format json` to retrieve the project fields. Find the "Status" field ID and the "In progress" option ID from the JSON output.

5. **Update Issue Status**: Use the command `gh project item-edit --id ITEM_ID --project-id PROJECT_ID --field-id FIELD_ID --single-select-option-id OPTION_ID` to update the status to "In progress". Replace the placeholders with the values obtained in previous steps.

6. **Handle Errors**: Ensure to handle potential errors, such as invalid URLs, non-existent issues, issues not linked to a project, missing authentication scopes, and network issues. Provide clear error messages for each scenario.

7. **Confirm Success**: After successfully updating the status, verify the update by running `gh issue view ISSUE_NUMBER --json projectItems` and confirm with a success message.

## Example Commands
```bash
# Step 2: Get project information
gh project list --owner Tasup --format json

# Step 3: Get project item ID
gh project item-list 1 --owner Tasup --format json --limit 100

# Step 4: Get field information
gh project field-list 1 --owner Tasup --format json

# Step 5: Update status
gh project item-edit --id PVTI_xxx --project-id PVT_xxx --field-id PVTSSF_xxx --single-select-option-id 47fc9ee4

# Step 7: Verify update
gh issue view 5 --json projectItems
```
## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.


