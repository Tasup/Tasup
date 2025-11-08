---
name: auto-update-issue-status-from-todo-to-in-progress
description: Automatically update GitHub Issue status to the next stage (Todo→In Progress→Done) in all linked projects.
---

# Auto Update Issue Status to Next Stage

## Instructions
Provide clear, step-by-step guidance for Claude.

**Important**: All GitHub CLI commands used in this skill are defined in `.claude/skills/gh-commands.md`. Refer to that file for command syntax and usage examples.

1. **Extract Information from URL**: Given a GitHub Issue URL (e.g., `https://github.com/Tasup/Tasup/issues/5`), extract the owner, repository name, and issue number.

2. **Get Project Information**: Refer to `.claude/skills/gh-commands.md` for the "Get project information" command. Execute it to retrieve the list of all projects. Extract each project's ID and number from the JSON output for processing in subsequent steps.

3. **Get Project Item ID and Current Status for All Projects**:
   - For each project obtained in step 2, refer to `.claude/skills/gh-commands.md` for the "Get project item ID" command.
   - For each project, find the item that matches the issue number and extract its ID.
   - Parse each item's `fieldValues` to find the current status value.
   - Collect all projects where the issue is found. If the issue is not found in any project, return an error: "Issue is not linked to any project."

4. **Get Field Information for All Projects**: For each project where the issue was found in step 3, refer to `.claude/skills/gh-commands.md` for the "Get field information" command. For each project, find the "Status" field and extract:
   - Field ID
   - All status option IDs and their names (Todo, In Progress, Done)
   - If the Status field doesn't exist in any project, return an error: "Status field not found in project [PROJECT_NAME]."

5. **Determine Next Status**:
   - If current status is "Todo", next status is "In Progress"
   - If current status is "In Progress", next status is "Done"
   - If current status is "Done", skip the update and return a message: "Issue is already in Done status. No update needed."
   - If current status is not one of the expected values (Todo/In Progress/Done):
     * Inform the user that the current status "[STATUS_NAME]" is not part of the automatic Todo→In Progress→Done flow
     * Automatically invoke the `update-issue-status` skill by using the Skill tool: `Skill(update-issue-status-from-todo-to-in-progress)`
     * The update-issue-status skill will present all available statuses to the user for interactive selection
     * Do NOT return an error - instead, gracefully transition to the interactive skill

6. **Update Issue Status in All Projects**: For each project where the issue was found, refer to `.claude/skills/gh-commands.md` for the "Update issue status" command. Execute it with the values obtained in previous steps to update the status to the next stage in all linked projects. Track which projects were successfully updated and which failed (if any).

7. **Handle Errors**: Ensure to handle potential errors, such as:
   - Invalid URLs
   - Non-existent issues
   - Issues not linked to a project
   - Missing Status field in project
   - Missing authentication scopes (project permissions)
   - Network issues
   Provide clear error messages for each scenario.

   Note: Statuses outside the Todo→In Progress→Done flow are handled in step 5 with a suggestion to use the alternative skill, not as errors.

8. **Confirm Success**: Refer to `.claude/skills/gh-commands.md` for the "Verify update" command. After successfully updating the status in all projects, verify the updates and confirm with a success message that includes:
   - The number of projects updated
   - The previous status and new status for each project
   - The project names
   - Example: "Successfully updated issue #5 in 2 projects:
     - Project 'Tasup Project': 'Todo' → 'In Progress'
     - Project 'Tasup Experiment': 'TODO' → 'In progress'"
   - If some projects failed to update, list both successful and failed projects with reasons for failures.

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
- This skill targets **all projects** linked to the issue.
- The status transition flow is strictly: **Todo → In Progress → Done**
- Issues already in "Done" status in all projects will not be modified.
- Status names are case-sensitive. Common variations include:
  - "Todo" or "TODO"
  - "In Progress" or "In progress"
  - "Done"
- **For issues with statuses outside this flow** (e.g., "In review", "Backlog", "Ready"), this skill will suggest using the `update-issue-status` skill instead, which supports manual selection of any available status.
- If an issue is linked to multiple projects, the skill will update the status in all of them.
- If the issue has different statuses across projects (e.g., "Todo" in one, "In Progress" in another), each project will be advanced to its respective next status.
- Partial failures are handled gracefully: if some projects update successfully while others fail, the success message will list both outcomes.
