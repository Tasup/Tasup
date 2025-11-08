# GitHub CLI Commands for Project Status Update

## Commands

### Get project information
```bash
gh project list --owner OWNER --format json
```

### Get project item ID
```bash
gh project item-list PROJECT_NUMBER --owner OWNER --format json --limit 100
```

### Get field information
```bash
gh project field-list PROJECT_NUMBER --owner OWNER --format json
```

### Update issue status
```bash
gh project item-edit --id ITEM_ID --project-id PROJECT_ID --field-id FIELD_ID --single-select-option-id OPTION_ID
```

### Verify update
```bash
gh issue view ISSUE_NUMBER --json projectItems
```

### Get parent issue (REST API - Recommended)
Get the parent issue using REST API. This returns a single parent issue object:
```bash
gh api /repos/OWNER/REPO/issues/ISSUE_NUMBER/parent
```

Response includes:
- `number`: Parent issue number
- `title`: Parent issue title
- `sub_issues_summary`: Summary of all child issues (total, completed, percent_completed)

**Note**: Use this REST API method instead of GraphQL `trackedInIssues` as it's more reliable and returns the direct parent issue.

### Get parent issues (GraphQL - Deprecated)
**DEPRECATED**: This GraphQL method may not return results reliably. Use the REST API method above instead.

Get all parent issues that track the current issue using GraphQL:
```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    issue(number: ISSUE_NUMBER) {
      number
      title
      trackedInIssues(first: 10) {
        nodes {
          number
          title
        }
      }
    }
  }
}'
```

### Get child issues (tracked issues)
Get all child issues tracked by the current issue:
```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    issue(number: ISSUE_NUMBER) {
      number
      title
      trackedIssues(first: 10) {
        nodes {
          number
          title
        }
      }
    }
  }
}'
```

## Example Usage
```bash
# Get project information
gh project list --owner Tasup --format json

# Get project item ID
gh project item-list 1 --owner Tasup --format json --limit 100

# Get field information
gh project field-list 1 --owner Tasup --format json

# Update status
gh project item-edit --id PVTI_xxx --project-id PVT_xxx --field-id PVTSSF_xxx --single-select-option-id 47fc9ee4

# Verify update
gh issue view 5 --json projectItems

# Get parent issue for issue #33 (REST API)
gh api /repos/Tasup/Tasup/issues/33/parent

# Get parent issues for issue #33 (GraphQL - Legacy)
gh api graphql -f query='
{
  repository(owner: "Tasup", name: "Tasup") {
    issue(number: 33) {
      number
      title
      trackedInIssues(first: 10) {
        nodes {
          number
          title
        }
      }
    }
  }
}'

# Get child issues for issue #8
gh api graphql -f query='
{
  repository(owner: "Tasup", name: "Tasup") {
    issue(number: 8) {
      number
      title
      trackedIssues(first: 10) {
        nodes {
          number
          title
        }
      }
    }
  }
}'
```
