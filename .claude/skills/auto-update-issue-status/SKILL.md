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

9. **Update Parent Issue Status (Optional)**:
   After successfully updating the child issue status, check and update parent issues if applicable:

   a. **Get Parent Issues**:
      - Refer to `.claude/skills/gh-commands.md` for the "Get parent issues (tracked in issues)" command.
      - Execute the GraphQL query to retrieve all parent issues that track the current issue.
      - Extract the list of parent issue numbers from the response.
      - If there are no parent issues (`trackedInIssues.nodes` is empty), skip to final confirmation.

   b. **For Each Parent Issue**:
      For each parent issue number found, perform the following steps:

      i. **Get Project Information**: Use the "Get project information" command from `.claude/skills/gh-commands.md` to retrieve the project ID and number.

      ii. **Get Project Item ID and Current Status**:
         - Use the "Get project item ID" command to find the parent issue's item ID.
         - Extract the current status value from `fieldValues`.
         - If not found in project, log warning and skip to next parent.

      iii. **Get Field Information**: Use the "Get field information" command to get the Status field ID and all option IDs.

      iv. **Check All Child Issues Status**:
         - Use the "Get child issues (tracked issues)" command from `.claude/skills/gh-commands.md`.
         - Execute the GraphQL query to get all child issues tracked by the parent.
         - For each child issue, get its current status from the project.
         - Determine the appropriate parent status:
           - If ALL child issues are "Done" → parent should be "Done"
           - If ANY child issue is "In Progress" → parent should be "In Progress"
           - If ALL child issues are "Todo" → parent should be "Todo"
           - Otherwise → parent should be "In Progress" (mixed statuses)

      v. **Update Parent Issue Status**:
         - If determined status differs from current status, use the "Update issue status" command.
         - If status is the same, skip update and log message.
         - Verify the update using the "Verify update" command.

   c. **Handle Parent Update Errors**: For each parent issue, handle errors gracefully:
      - Continue processing other parents if one fails
      - Log clear error messages
      - Don't fail the entire workflow if parent updates fail

10. **Final Confirmation**: Provide a comprehensive summary that includes:
    - Child issue status update (old status → new status)
    - Number of parent issues found
    - Number of parent issues successfully updated
    - List of updated parent issues with their status changes
    - Any warnings or skipped parents
    - Example: "Successfully updated issue #5 from 'Todo' to 'In Progress'. Found 2 parent issues: updated #3 from 'Todo' to 'In Progress', #7 was already 'In Progress'."

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- This skill targets the **first project** linked to the issue.
- The status transition flow is strictly: **Todo → In Progress → Done**
- Issues already in "Done" status will not be modified.
- Status names are case-sensitive and should match: "Todo", "In Progress", "Done"
- Parent issue updates are performed automatically after child issue update succeeds.
- Parent status is determined by aggregating all child issue statuses.
- Parent update failures do not affect the child issue update success.
- All GitHub CLI commands are defined in `.claude/skills/gh-commands.md`.
