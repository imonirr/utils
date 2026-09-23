## Repository Layout

Repositories use a Git worktree setup and follow this structure:

```bash
my-project/
├── .git/                    (bare git metadata)
├── main/                    (main branch worktree)
└── <full-branch-name>/      (branch worktree when needed)
```

Operational notes:

- Run day-to-day Git commands from a worktree folder (for example `main/` or `<branch-name>/`), not from the repository root.
- Use repository root only for bare-repo commands such as `git --git-dir <repo>/.git worktree list`.
- For any file/code change, first create a branch and check it out as its own worktree folder inside the bare repository, then do the work there.
- Worktree folder names must match the full branch name (for example branch `add-password-rememberme-feature` uses folder `add-password-rememberme-feature`).

## Principles

- always do proper error handling. good to add try cache pattern where we know known exceptions can happen. i.e file, network io etc. so a clear exception message instead of long stack trace makes debuggin easier and keeps logs clean

## Testing

- Tautological tests considered
- Change detector tests considered harmful
- Do not create regression tests for bug fixes without a genuine gap in behavior testing
- Never write unit tests after you write code
- Highly prefer E2E tests as the sole testing mechanism. Use them to verify complex features work. At the end of E2E tests, produce a verifable and repeatable artifact
- If you must test a system in isolation, FIRST write all the ways it could fail, THEN write the code

## Code quality check

- **Diagnostic Verification**: After editing or creating files, check active LSP diagnostics if any
- **Auto-Triage**: Clear code smells, or security warnings before finishing the task.
