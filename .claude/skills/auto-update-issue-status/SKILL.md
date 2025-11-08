---
name: auto-update-issue-status-from-todo-to-in-progress
description: Automatically update GitHub Issue status to the next stage (Todo→In Progress→Done) in the first linked project.
---

# Auto Update Issue Status to Next Stage

## Instructions
Provide clear, step-by-step guidance for Claude.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Get Project Information**: Use the command `gh project list --owner OWNER --format json` to retrieve the list of projects. Extract the first project's ID and number from the JSON output.

3. **Get Project Item ID and Current Status**:
   - Use the command `gh project item-list PROJECT_NUMBER --owner OWNER --format json --limit 100` to retrieve all project items.
   - Find the item that matches the issue number and extract its ID.
   - Parse the item's `fieldValues` to find the current status value.
   - If the issue is not found in the project items, return an error: "Issue is not linked to any project."

4. **Get Field Information**: Use the command `gh project field-list PROJECT_NUMBER --owner OWNER --format json` to retrieve the project fields. Find the "Status" field and extract:
   - Field ID
   - All status option IDs and their names (Todo, In Progress, Done)
   - If the Status field doesn't exist, return an error: "Status field not found in project."

5. **Determine Next Status**:
   - If current status is "Todo", next status is "In Progress"
   - If current status is "In Progress", next status is "Done"
   - If current status is "Done", skip the update and return a message: "Issue is already in Done status. No update needed."
   - If current status is not one of the expected values, return an error: "Unknown current status: [STATUS_NAME]"

6. **Update Issue Status**: Use the command `gh project item-edit --id ITEM_ID --project-id PROJECT_ID --field-id FIELD_ID --single-select-option-id NEXT_OPTION_ID` to update the status to the next stage. Replace the placeholders with the values obtained in previous steps.

7. **Handle Errors**: Ensure to handle potential errors, such as:
   - Invalid URLs
   - Non-existent issues
   - Issues not linked to a project
   - Missing Status field in project
   - Missing authentication scopes (project permissions)
   - Network issues
   - Unknown or unexpected status values
   Provide clear error messages for each scenario.

8. **Confirm Success**: After successfully updating the status, verify the update by running `gh issue view ISSUE_NUMBER --json projectItems` and confirm with a success message that includes:
   - The previous status
   - The new status
   - Example: "Successfully updated issue #5 from 'Todo' to 'In Progress'"

## Example Commands
```bash
# Step 2: Get project information
gh project list --owner Tasup --format json

# Step 3: Get project item ID and parse current status
gh project item-list 1 --owner Tasup --format json --limit 100

# Example of parsing current status from JSON output:
# Look for the item matching your issue number, then find the Status field value

# Step 4: Get field information (all status options)
gh project field-list 1 --owner Tasup --format json

# Example output processing:
# Find the field with name "Status"
# Extract field ID and all option IDs for: Todo, In Progress, Done

# Step 6: Update status (example transitioning from Todo to In Progress)
gh project item-edit --id PVTI_xxx --project-id PVT_xxx --field-id PVTSSF_xxx --single-select-option-id 47fc9ee4

# Step 8: Verify update
gh issue view 5 --json projectItems
```

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- This skill targets the **first project** linked to the issue.
- The status transition flow is strictly: **Todo → In Progress → Done**
- Issues already in "Done" status will not be modified.
- Status names are case-sensitive and should match: "Todo", "In Progress", "Done"
