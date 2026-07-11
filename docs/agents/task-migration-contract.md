# RaVN task migration contract

Legacy tasks are migrated one at a time. A migration is complete only when the
new active descriptor passes its backend contract, isolated Docker test, and
the applicable manual host validation.

## Procedure

1. Select exactly one file from `Scripts/ravn/tasks_legacy/` and create an issue
   that records its package, command, installer strategy, dependencies, and
   known edge cases.
2. Create an issue worktree from `RaVN-VM_Refactor` with
   `/home/ravn/.local/bin/git-issue-worktree`.
3. Add one canonical descriptor under the appropriate active category. For a
   mise-managed npm CLI, the descriptor should declare only `CLI_PACKAGE` and
   `CLI_COMMAND`, source `framework/mise-cli.sh`, and call `mise_cli_task`.
4. Preserve the legacy file until the replacement passes validation. Do not
   modify or bulk-migrate unrelated tasks.
5. Validate the descriptor with Bash syntax checks, ShellCheck, shfmt, the
   deterministic framework tests, and the isolated Docker task test.
6. Exercise clean install, rerun, real command verification from a clean shell,
   update, failed update/rollback, reset, and reinstall where the backend
   supports those operations.
7. Record matrix layers as `PASS`, `FAIL`, `SKIPPED`, `UNSUPPORTED`, or
   `NOT_RUN`. The `all` matrix must fail closed when required manual validation
   was not executed.
8. Review, commit, push, merge into the recorded base branch, close the issue,
   and remove the issue worktree plus local and remote topic branches.

## Current migration state

- `00-core` and `30-system` remain quarantined under `tasks_legacy` and are
  reported as legacy coverage until canonical replacements are designed.
- `10-npm-apps/11-codex.sh` is the second active canonical npm descriptor.
- `10-npm-apps/12-copilot.sh` is the third active canonical npm descriptor.
- `10-npm-apps/24-zero.sh` is the fourth active canonical npm descriptor.
- `10-npm-apps/28-opencode.sh` is the first active canonical npm descriptor.
- `10-npm-apps/28-opencode-mise.sh` remains reference-only and is excluded from
  normal discovery and `ALL` tests.
- Codex is the next individual npm CLI migration.
