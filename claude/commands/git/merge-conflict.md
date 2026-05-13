# Context

Arguments: $ARGUMENTS
Current branch: !`git branch --show-current`
Merge state: !`test -f "$(git rev-parse --git-dir)/MERGE_HEAD" && echo "MERGE_IN_PROGRESS" || (test -d "$(git rev-parse --git-dir)/rebase-merge" && echo "REBASE_IN_PROGRESS") || (test -d "$(git rev-parse --git-dir)/rebase-apply" && echo "REBASE_IN_PROGRESS") || echo "NO_ACTIVE_MERGE"`
Unmerged files: !`git diff --name-only --diff-filter=U 2>/dev/null || echo "None"`
Working tree status: !`git status --short`
Conflict diffs: !`git diff --diff-filter=U 2>/dev/null || echo "No conflict diffs"`

## Your Task

You are analyzing merge conflicts. You did NOT write either side of these conflicts. Treat both sides as code written by other developers. Do not assume either side is "correct" -- assess each change on its own merit.

### Mode detection

Determine which mode applies based on the context above:

**1. Active conflict** -- `Merge state` shows `MERGE_IN_PROGRESS` or `REBASE_IN_PROGRESS` AND `Unmerged files` lists files.
Proceed to per-file analysis and resolution planning below.

**2. Preview mode** -- `Merge state` shows `NO_ACTIVE_MERGE`.
Use the branch from `Arguments` if provided, otherwise default to `main`.
Run `git merge-tree $(git merge-base HEAD <branch>) HEAD <branch>` or `git diff HEAD...<branch>` to identify files that would conflict. Proceed to per-file analysis for those files.

If mode 1 or 2 applies, **enter plan mode.** Your resolution plan is the plan. The developer will approve it before any changes are made.

### Per-file analysis

For each conflicted file:
1. **Classify the file** -- source code, config, lock file (package-lock.json, yarn.lock, Gemfile.lock, etc.), generated file, binary, migration, schema
2. **Understand both sides** -- what was the intent of each side's changes? Read the surrounding context, not just the conflict markers.
3. **Assign a resolution strategy:**

| Strategy | When to use |
|---|---|
| **KEEP OURS** | Their side's changes are fully superseded or reverted by ours |
| **KEEP THEIRS** | Our side's changes are fully superseded or reverted by theirs |
| **SYNTHESIZE** | Both sides made meaningful changes that should coexist -- combine them |
| **REGENERATE** | Lock files, generated files -- delete conflict markers and regenerate from source |
| **MANUAL** | Binary files, ambiguous intent, or cases where you cannot determine correctness |

Default to **SYNTHESIZE** for logic conflicts. Do not blindly pick a side when both sides made intentional changes.

Always use **REGENERATE** for lock files. Never manually resolve lock file conflicts.

Always classify binary files as **MANUAL**.

### Output structure

**1. Situation assessment** (3-5 lines)
- Which mode (active conflict / preview)
- Current branch and the other branch involved
- Total number of conflicted files
- Type of merge operation (merge / rebase)

**2. Per-file resolution plan**
For each file, in order:
- **[STRATEGY]** `file path`
- **Ours:** what our side changed and why (inferred from diff context)
- **Theirs:** what their side changed and why
- **Resolution:** concrete description of what the resolved file should look like
- **Risk:** any risk of the proposed resolution (or "Low" if straightforward)

**3. Resolution sequence**
Ordered checklist of steps to execute the resolutions. Group by strategy type:
1. REGENERATE files first (lock files)
2. KEEP OURS / KEEP THEIRS files next (simple checkouts)
3. SYNTHESIZE files last (require careful editing)
4. MANUAL files noted as requiring developer decision

For each step, include the exact commands or actions to take.

**4. Post-resolution verification**
- Commands to verify the merge result compiles/passes lint
- Files to review after resolution
- How to complete the merge/rebase (e.g., `git rebase --continue`, `git commit`)

### Conduct

- Never silently drop changes from either side. Every change from both sides must be accounted for in the resolution.
- Be direct about which side's changes take priority and why.
- If you cannot determine the intent of a change, classify as MANUAL and say so explicitly.
- Do not invent conflicts that do not exist in the diff.
- When both sides modified the same lines with different intent, explain the trade-off clearly.
- If preview mode shows no potential conflicts, say so and stop.
