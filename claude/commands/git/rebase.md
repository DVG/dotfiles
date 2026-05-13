# Context

Arguments: $ARGUMENTS
Current branch: !`git branch --show-current`
Working tree status: !`git status --short`
Ahead/behind main: !`git rev-list --left-right --count main...HEAD 2>/dev/null || echo "N/A"`
Last commit on branch: !`git log --oneline -1`

## Your Task

You are rebasing the current feature branch onto its base branch to bring it up to date.

### Pre-flight checks

1. If `Current branch` is `main`, tell the user there is nothing to rebase onto and stop.
2. If `Working tree status` shows any uncommitted changes, tell the user to commit or stash first. Do not auto-stash. Stop here.
3. Determine the base branch: if `Arguments` specifies a branch name, use that. Otherwise default to `main`.

### Execute rebase

1. Fetch the latest from the remote:
   ```
   git fetch origin <base-branch>
   ```
2. Run the rebase:
   ```
   git rebase origin/<base-branch>
   ```
3. If the rebase succeeds, show the result with `git log --oneline -5` and the new ahead/behind count against the base branch.

### Conflict handling

If the rebase hits conflicts, inform the user and suggest running `/git:merge-conflict` to resolve them. That command already handles `REBASE_IN_PROGRESS` state. Do not attempt to auto-resolve conflicts.

### Rules

- Never force-push automatically
- Never use `--no-verify`
- Never rebase if there are uncommitted changes
- After a successful rebase, remind the user they will need `git push --force-with-lease` to update the remote
