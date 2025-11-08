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
```
