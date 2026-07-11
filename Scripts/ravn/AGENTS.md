# RaVN task development guide

This directory contains the RaVN task runner. An agent adding or migrating a
task must treat the task's observable behavior as the deliverable: the task
must install the tool, verify that the tool actually runs, and fail clearly
when dependencies or postconditions are missing.

## Where tasks belong

Active task modules live under:

```text
Scripts/ravn/tasks/<category>/<number>-<name>.sh
```

Use the existing category that matches the responsibility:

- `tasks/10-npm-apps/` — npm CLIs and npm-backed application tools.
- `tasks/20-shell/` — shell tools and shell configuration tasks.
- Add a new category only when an existing category cannot express the task;
  document the new category here and update discovery tests.

Legacy modules live under `tasks_legacy/`. Do not edit or delete a legacy task
while migrating it. Add one active replacement, validate it, and remove or
quarantine the legacy module only through an explicitly reviewed migration.

Files are discovered automatically with `find tasks/ -name "*.sh" | sort`.
There is no task registry to edit. Numeric prefixes control ordering, so retain
the legacy task's number when the replacement is a one-for-one migration.

For issue work, create the worktree with:

```bash
/home/ravn/.local/bin/git-issue-worktree \
  -r /home/ravn/Work/Rollo/dev \
  -B origin/dev \
  <issue-number> <slug>
```

Options must precede the issue number. This repository uses `origin/dev`, not
`origin/main`.

Do not commit directly to `dev`; use the issue worktree, then push a branch and
merge through a pull request.

## Canonical npm CLI task shape

For a versioned npm CLI, the task file should contain only the CLI-specific
identity and the shared mise entrypoint:

```bash
#!/usr/bin/env bash

# shellcheck disable=SC2034
CLI_PACKAGE="@openai/codex"
# shellcheck disable=SC2034
CLI_COMMAND="codex"

ravn_mise_cli_task
```

Replace the values with the actual npm package and executable command. For
example, GitHub Copilot uses `CLI_PACKAGE="@github/copilot"` and
`CLI_COMMAND="copilot"`.

### Meaning of the two required fields

`CLI_PACKAGE` is the exact npm package specifier passed to mise. It may include
an npm scope, such as `@openai/codex`. Do not use the executable name when the
package name differs. Do not add `npm:` here; the shared backend adds that
prefix when writing `mise.toml`.

`CLI_COMMAND` is the executable the package exposes and the command used for
real verification. It is also used to derive the task identity, the wrapper
name in `$HOME/.local/bin`, and the task-owned state directory. It must be the
actual command available after installation, not a display name.

The `# shellcheck disable=SC2034` comments are intentional: the variables are
read by the shared backend after the task file is sourced. Keep the directive
on the variable declaration; do not disable ShellCheck for the whole file.

Do not copy the old `omarchy-npx-install` implementation into a new canonical
task. `mise` is the standard backend for versioned npm CLIs. The shared
`ravn_mise_cli_task` entrypoint loads `framework/mise-cli.sh` and supplies the
canonical lifecycle, including dependency handling, install, real command
verification, update, rollback, reset, and evidence recording.

If a package cannot use the generic mise backend, stop and document the reason
in the issue before introducing a custom implementation.

## Task contract and ownership

The shared backend populates the task metadata and lifecycle functions. A
canonical task must therefore be executable without shell initialization and
must not open a TUI or prompt for credentials.

The backend owns these resources for a CLI command `<command>`:

- mise configuration and installed tool state under
  `${XDG_DATA_HOME:-$HOME/.local/share}/ravn/tasks/<command>`;
- the single active wrapper at `$HOME/.local/bin/<command>`;
- task evidence and audit state managed by the runner.

The active wrapper must be the only exposed command for the task. Do not create
additional global symlinks or wrappers. Keep the legacy descriptor unchanged
until the replacement has passed validation.

The generic backend uses `latest` for explicit update policy, not as a reason
for ordinary `run` to update a verified installation. It manages Node through
mise, enables required npm lifecycle scripts, verifies the real command, and
retains the previous verified configuration where rollback is possible.

## Mandatory testing workflow

Testing is the most important part of adding a task. A task is not complete
because npm exited successfully or because a wrapper file exists. Every new or
migrated task must prove that the installed command is usable in a clean
environment.

Run these checks from the repository root or adjust paths accordingly.

### 1. Static checks first

```bash
bash -n Scripts/ravn/tasks/10-npm-apps/<number>-<name>.sh
shellcheck Scripts/ravn/tasks/10-npm-apps/<number>-<name>.sh
shfmt -d Scripts/ravn/tasks/10-npm-apps/<number>-<name>.sh
git diff --check
```

Fix every ShellCheck warning. Do not use a broad disable directive to hide a
real problem. Use the repository's Bash style: quote command arguments, use
`[[ ]]` for tests, localize function variables, and preserve non-zero statuses.

### 2. Discovery and deterministic framework tests

```bash
bash Scripts/ravn/tests/discovery.sh
bash Scripts/ravn/tests/contract.sh
bash Scripts/ravn/tests/runner.sh
bash Scripts/ravn/tests/state.sh
bash Scripts/ravn/tests/mise.sh
bash Scripts/ravn/tests/menu.sh
bash Scripts/ravn/tests/opencode-contract.sh
bash Scripts/ravn/tests/dry-run.sh
bash Scripts/ravn/tests/test-task-selection.sh
```

If adding a canonical task changes the discovered task count, update the
discovery assertion and verify that no `tasks_legacy` file is discovered.
Never weaken the test to make a task disappear.

### 3. Isolated Docker test — required

For an npm CLI, run the real isolated test:

```bash
bash Scripts/ravn/test-task.sh <command>
```

For example:

```bash
bash Scripts/ravn/test-task.sh codex
bash Scripts/ravn/test-task.sh copilot
bash Scripts/ravn/test-task.sh 10-npm-apps
```

This test starts a clean Arch container, bootstraps the pinned mise fixture,
installs Node and the npm package, invokes the task's `install()`, and then
executes the task's real `verify()` path. A successful result must say
`<package> → PASÓ`; a merely successful installer exit is insufficient.

Use `--mise-version <version>` only when reproducing a known fixture issue.
Use `--keep` when a failure needs container inspection; remove the container
after debugging. Use `--dry-run` only to inspect control flow — it does not
prove installation or command usability.

Reference-only tasks are excluded from category and `--all` selectors by
default. They appear in the summary as `Omitidas (reference)`, not as
`No verificables`. Pass `--include-reference` to run them in Docker.

A skipped reference task is not a failed active task, but it also is not
evidence that the canonical task works.

### 4. Lifecycle behavior to exercise

For every mise CLI task, validate as many of these operations as the backend
supports:

```bash
bash Scripts/ravn/setup.sh run <command>
bash Scripts/ravn/setup.sh verify <command>
bash Scripts/ravn/setup.sh check-updates <command>
bash Scripts/ravn/setup.sh update <command>
bash Scripts/ravn/setup.sh reset <command> --yes
```

In non-interactive environments (agents, CI, pipes without a TTY), `reset`
requires `--yes`. Without it, the runner exits with a clear error instead of
waiting for confirmation or recording a misleading `reset-refused`.

At minimum, prove:

1. clean install in an empty state directory;
2. real `<command> --version` (or the task's declared verification arguments)
   from the generated wrapper;
3. a second `run`/verification is idempotent and does not unexpectedly update;
4. update is explicit and records the resolved package and Node versions;
5. a failed candidate does not replace the previous verified version;
6. reset removes only resources owned by this task;
7. verification after reset reports absence or a dependency state; and
8. reinstall after reset succeeds.

When a scenario cannot run because the host lacks mise, network access, or a
required platform, record it as `SKIPPED`, `UNSUPPORTED`, or `NOT_RUN` with the
reason. Never report it as `PASS`, and never turn a missing dependency into a
successful install.

### 5. Full repository gates before commit

```bash
find Scripts/ravn -name '*.sh' -type f -exec bash -n {} +
find Scripts/ravn -name '*.sh' -type f -print0 | xargs -0 shellcheck
shfmt -d Scripts/ravn
flg_DryRun=1 bash Scripts/ravn/setup.sh
bash Scripts/ravn/tests/dry-run.sh
bash Scripts/ravn/test-task.sh --all
git diff --check
```

`flg_DryRun=1 bash Scripts/ravn/setup.sh` runs the discovered active-task
pipeline in dry-run mode (no menu, no install). In a non-interactive shell,
`setup.sh` without a subcommand exits with usage guidance instead of opening
the TUI.

The full Docker matrix can require network access and may take time. If it
cannot run, report the exact command and reason in the handoff; do not claim
the task is fully validated. Run the focused task test again after every fix.

## Failure diagnosis

- `dependency-missing`: mise or another required runtime is unavailable;
  verify the injected binary path and bootstrap policy.
- install failure: inspect the task log and the mise/npm resolution output;
  do not create a wrapper manually.
- verification failure: run the wrapper directly with its verification args;
  check the resolved package version, Node version, and lifecycle scripts.
- `update-failed`: confirm the previous verified configuration remains active.
- `rollback-failed`: treat as a blocking reliability failure; do not merge.
- Docker `NO VERIFICABLE`: inspect `TEST_LEVEL` and whether `verify()` is
  available; do not interpret it as success. Reference-only omissions are
  reported separately and are not failures.
- `reset` without `--yes` in a non-interactive shell: pass `--yes` explicitly.
- `setup.sh` with no subcommand in a non-interactive shell: use
  `run|verify|reset|update|check-updates <command>` or `flg_DryRun=1` for the
  pipeline gate.

## Completion checklist

Before opening a PR, confirm all of the following:

- The task is under the correct active category and has the correct numeric
  filename prefix.
- `CLI_PACKAGE` is the exact npm package and `CLI_COMMAND` is the real binary.
- The task uses `ravn_mise_cli_task` unless an issue documents an exception.
- The legacy task is preserved and unrelated tasks are untouched.
- Static, deterministic, and isolated Docker checks pass.
- The real command was executed from a clean environment.
- Any skipped or unsupported matrix layer is explicitly reported.
- The issue, commit, PR, and merge target are linked.
- The PR is merged into the recorded base branch before deleting its worktree
  or local/remote topic branches.
