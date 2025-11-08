---
name: update-parent-issue-status
description: Update the status of all parent issues (tracked in issues) when a child issue status changes.
---

# Update Parent Issue Status

## Instructions
Provide clear, step-by-step guidance for Claude.

**Important**: All GitHub CLI commands used in this skill are defined in `.claude/skills/gh-commands.md`. Refer to that file for command syntax and usage examples.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/33`), extract the owner, repository name, and issue number.

2. **Get Parent Issues**:
   - Refer to `.claude/skills/gh-commands.md` for the "Get parent issues (tracked in issues)" command.
   - Execute the GraphQL query to retrieve all parent issues that track the current issue.
   - Extract the list of parent issue numbers from the response.
   - If there are no parent issues (`trackedInIssues.nodes` is empty), return a message: "No parent issues found. This issue is not tracked by any parent issue."

3. **For Each Parent Issue, Update Status**:
   For each parent issue number found in step 2, perform the following steps:

   a. **Get Project Information**: Refer to `.claude/skills/gh-commands.md` for the "Get project information" command. Execute it to retrieve the list of projects and extract the first project's ID and number from the JSON output.

   b. **Get Project Item ID and Current Status**:
      - Refer to `.claude/skills/gh-commands.md` for the "Get project item ID" command.
      - Find the item that matches the parent issue number and extract its ID.
      - Parse the item's `fieldValues` to find the current status value.
      - If the parent issue is not found in the project items, log a warning: "Parent issue #X is not linked to any project. Skipping." and continue to the next parent issue.

   c. **Get Field Information**: Refer to `.claude/skills/gh-commands.md` for the "Get field information" command. Find the "Status" field and extract:
      - Field ID
      - All status option IDs and their names (Todo, In Progress, Done)
      - If the Status field doesn't exist, log a warning: "Status field not found in project for parent issue #X. Skipping." and continue to the next parent issue.

   d. **Check All Child Issues Status**:
      - Refer to `.claude/skills/gh-commands.md` for the "Get child issues (tracked issues)" command.
      - Execute the GraphQL query to get all child issues tracked by the parent issue.
      - For each child issue, get its current status from the project.
      - Determine the appropriate parent status based on child statuses:
        - If ALL child issues are "Done", parent should be "Done"
        - If ANY child issue is "In Progress", parent should be "In Progress"
        - If ALL child issues are "Todo", parent should be "Todo"
        - Otherwise, parent should be "In Progress" (mixed statuses)

   e. **Update Parent Issue Status**:
      - Compare the determined status with the current parent status.
      - If they are the same, skip the update and log: "Parent issue #X is already in the correct status. No update needed."
      - If they are different, refer to `.claude/skills/gh-commands.md` for the "Update issue status" command.
      - Execute it with the values obtained in previous steps to update the parent status.

   f. **Verify Update**: Refer to `.claude/skills/gh-commands.md` for the "Verify update" command. After successfully updating the status, verify the update.

4. **Handle Errors**: Ensure to handle potential errors for each parent issue, such as:
   - Invalid URLs
   - Non-existent issues
   - Issues not linked to a project
   - Missing Status field in project
   - Missing authentication scopes (project permissions)
   - Network issues
   - GraphQL API errors
   Provide clear error messages for each scenario and continue processing other parent issues if one fails.

5. **Confirm Success**: After processing all parent issues, provide a summary message that includes:
   - Total number of parent issues found
   - Number of parent issues successfully updated
   - Number of parent issues skipped (with reasons)
   - List of updated parent issues with their previous and new statuses
   - Example: "Successfully updated 2 parent issues: #8 from 'Todo' to 'In Progress', #6 from 'In Progress' to 'Done'. Skipped 1 parent issue: #4 (already in correct status)."

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- This skill processes **all parent issues** that track the current issue.
- Parent status is determined by aggregating the status of all child issues:
  - All Done → Parent Done
  - Any In Progress → Parent In Progress
  - All Todo → Parent Todo
  - Mixed → Parent In Progress
- Parent issues already in the correct status will not be modified to avoid unnecessary API calls.
- The skill handles multiple levels of hierarchy (grandparent issues are not automatically updated, only direct parents).
- If a parent issue is not linked to any project, it will be skipped with a warning.
