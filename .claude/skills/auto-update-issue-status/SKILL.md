---
name: auto-update-issue-status-from-todo-to-in-progress
description: Automatically update GitHub Issue status to the next stage (Todo→In Progress→Done) in the first linked project.
---

# Auto Update Issue Status to Next Stage

## Instructions
Provide clear, step-by-step guidance for Claude.

**Important**: All GitHub CLI commands used in this skill are defined in `.claude/skills/gh-commands.md`. Refer to that file for command syntax and usage examples.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Get Project Information**: Refer to `.claude/skills/gh-commands.md` for the "Get project information" command. Execute it to retrieve the list of projects and extract the first project's ID and number from the JSON output.

3. **Get Project Item ID and Current Status**:
   - Refer to `.claude/skills/gh-commands.md` for the "Get project item ID" command.
   - Find the item that matches the issue number and extract its ID.
   - Parse the item's `fieldValues` to find the current status value.
   - If the issue is not found in the project items, return an error: "Issue is not linked to any project."

4. **Get Field Information**: Refer to `.claude/skills/gh-commands.md` for the "Get field information" command. Find the "Status" field and extract:
   - Field ID
   - All status option IDs and their names (Todo, In Progress, Done)
   - If the Status field doesn't exist, return an error: "Status field not found in project."

5. **Determine Next Status**:
   - If current status is "Todo", next status is "In Progress"
   - If current status is "In Progress", next status is "Done"
   - If current status is "Done", skip the update and return a message: "Issue is already in Done status. No update needed."
   - If current status is not one of the expected values, return an error: "Unknown current status: [STATUS_NAME]"

6. **Update Issue Status**: Refer to `.claude/skills/gh-commands.md` for the "Update issue status" command. Execute it with the values obtained in previous steps to update the status to the next stage.

7. **Handle Errors**: Ensure to handle potential errors, such as:
   - Invalid URLs
   - Non-existent issues
   - Issues not linked to a project
   - Missing Status field in project
   - Missing authentication scopes (project permissions)
   - Network issues
   - Unknown or unexpected status values
   Provide clear error messages for each scenario.

8. **Confirm Success**: Refer to `.claude/skills/gh-commands.md` for the "Verify update" command. After successfully updating the status, verify the update and confirm with a success message that includes:
   - The previous status
   - The new status
   - Example: "Successfully updated issue #5 from 'Todo' to 'In Progress'"

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- This skill targets the **first project** linked to the issue.
- The status transition flow is strictly: **Todo → In Progress → Done**
- Issues already in "Done" status will not be modified.
- Status names are case-sensitive and should match: "Todo", "In Progress", "Done"
