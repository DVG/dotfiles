# Context

Arguments: $ARGUMENTS
Current branch: !`git branch --show-current`
Working tree status: !`git status --short`
Staged diff: !`git diff --cached`
Staged files summary: !`git diff --cached --stat`
Recent commit style: !`git log --format="%B---" -5`

## Your Task

You are creating a commit for the currently staged changes.

### Pre-flight checks

1. If `Staged diff` is empty and `Working tree status` is also empty, say "Nothing to commit." and stop.
2. If `Staged diff` is empty and `Working tree status` shows modified/untracked files, stage all changed files with `git add -A` before proceeding.

### Analyze the staged diff

Read the full `Staged diff` and `Staged files summary` to understand:
- What changed (files, functions, logic)
- Why it changed (intent, context from surrounding code)

### Compose the commit message

- **Headline:** imperative mood ("Add", "Fix", "Update", not "Added", "Fixed", "Updated"), max ~72 characters, summarizes the *why* not the *what*.
- **Body:** separated from headline by a blank line, wrapped at ~72 characters. Explains context and reasoning when the headline alone isn't enough. Skip the body entirely for trivial or self-explanatory changes.
- Match the tone and conventions visible in `Recent commit style`.
- If `Arguments` contains a hint or description from the user, incorporate it into the message naturally. Treat it as guidance for the message content, not as the literal message text.

### Execute the commit

Run the commit using a HEREDOC for proper multi-line formatting:

```
git commit -m "$(cat <<'EOF'
Headline here

Body here if needed.
EOF
)"
```

### Show the result

After committing, run `git log --oneline -1` and display the resulting commit hash and message to confirm success.

### Rules

- Never add `Co-Authored-By` or any AI attribution lines
- If nothing is staged but there are working tree changes, stage all changed files automatically
- Never use `--no-verify` or skip pre-commit hooks
- Use imperative mood for the headline
- If a pre-commit hook fails, report the failure and stop -- do not retry or bypass
