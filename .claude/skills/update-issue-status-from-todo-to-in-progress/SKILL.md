---
name: update-issue-status
description: Update the status of a GitHub Issue to any available status in all linked projects using the `gh project item-edit` command. Allows interactive status selection via CLI.
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

2. **Get Project Information**: Refer to `.claude/skills/gh-commands.md` for the command to retrieve project information. Execute it to retrieve the list of all projects. Extract each project's ID and number from the JSON output for processing in subsequent steps.

3. **Get Project Item ID and Current Status for All Projects**:
   - For each project obtained in step 2, refer to `.claude/skills/gh-commands.md` for the command to retrieve project items.
   - For each project, find the item that matches the issue number and extract its ID and current status.
   - Collect all projects where the issue is found. If the issue is not found in any project, return an error: "Issue is not linked to any project."

4. **Get Field Information for All Projects**: For each project where the issue was found in step 3, refer to `.claude/skills/gh-commands.md` for the command to retrieve project fields. For each project, find the "Status" field ID and all available status options from the JSON output. If the Status field doesn't exist in any project, return an error: "Status field not found in project [PROJECT_NAME]."

5. **Present Current Status and Let User Select New Status**:
   - Display the current status of the issue in each project to the user in a text message.
   - If different projects have different current statuses, list them all.
   - Collect all unique available status options across all projects (excluding statuses that are already current in any project).
   - Use the AskUserQuestion tool with the following approach to handle more than 4 status options:

   **If there are 4 or fewer status options (excluding current statuses):**
   - Present all available statuses in a single AskUserQuestion
   - Question: "issue #NUMBER をどのステータスに変更しますか？現在のステータス: [list current statuses for each project]"
   - Header: "ステータス選択"
   - Options: List all available statuses

   **If there are more than 4 status options (excluding current statuses):**
   - First, display all available statuses in a text message to the user
   - Then ask the user which specific status they want to change to using AskUserQuestion with the first 4 most common statuses as options
   - The "Other" option will automatically be available for any status not in the initial 4
   - Common workflow statuses to prioritize: "Todo", "In progress", "In review", "Done"

6. **Update Issue Status in All Projects**: For each project where the issue was found, refer to `.claude/skills/gh-commands.md` for the command to update the issue status. Replace the placeholders with the values obtained in previous steps and the user-selected status option ID. Track which projects were successfully updated and which failed (if any).

7. **Handle Errors**: Ensure to handle potential errors, such as:
   - Invalid URLs
   - Non-existent issues
   - Issues not linked to a project
   - Missing Status field in project
   - Missing authentication scopes (project permissions)
   - Network issues
   Provide clear error messages for each scenario.

8. **Confirm Success**: Refer to `.claude/skills/gh-commands.md` for the command to verify the update. After successfully updating the status in all projects, verify the updates and confirm with a success message that includes:
   - The number of projects updated
   - The previous status and new status for each project
   - The project names
   - Example: "Successfully updated issue #5 in 2 projects:
     - Project 'Tasup Project': 'In progress' → 'Done'
     - Project 'Tasup Experiment': 'In progress' → 'Done'"
   - If some projects failed to update, list both successful and failed projects with reasons for failures.

## Command Reference
All required GitHub CLI commands are documented in `.claude/skills/gh-commands.md`. Refer to that file for:
- Getting project information
- Listing project items
- Retrieving field information
- Updating issue status
- Verifying updates

## Notes

- Ensure that the user has the necessary permissions and authentication scopes to perform these actions.
- This skill targets **all projects** linked to the issue.
- Status names are case-sensitive. Common variations include:
  - "Todo" or "TODO"
  - "In Progress" or "In progress"
  - "Done"
- If an issue is linked to multiple projects, the skill will update the status in all of them to the same user-selected status.
- If the issue has different statuses across projects, all projects will be updated to the newly selected status.
- Partial failures are handled gracefully: if some projects update successfully while others fail, the success message will list both outcomes.
- All command examples and usage patterns are maintained in `.claude/skills/gh-commands.md`


