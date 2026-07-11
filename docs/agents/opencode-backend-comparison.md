# OpenCode backend comparison

Ticket: #27  
Date: 2026-07-11

## Scope

This comparison covers only the two pilot tasks:

- `opencode-mise`: Node and `opencode-ai` are owned by an isolated mise configuration.
- `opencode-npx`: a wrapper delegates to the hardened `omarchy-npx-install` helper and owns only its wrapper.

The legacy `opencode` task and all other CLI tasks are out of scope.

## Executed lifecycle

| Scenario | mise | npx | Evidence |
| --- | --- | --- | --- |
| Clean reset | PASS | PASS | `setup.sh reset <task> --yes` |
| Clean install | PASS | PASS | `setup.sh run <task>` |
| Real command execution | PASS | PASS | `verify()` executes wrapper `--version` and receives output |
| Idempotent rerun | PASS | PASS | second `run` returns `skipped` after `check()` |
| Explicit verify | PASS | PASS | `setup.sh verify <task>` |
| Reset verification | PASS | PASS | runner reports reset completed and verified |
| Reinstall after reset | PASS | PASS | repeated clean cycle completed on host |
| Isolated Docker test | PASS | PASS | `bash Scripts/ravn/test-task.sh opencode-mise opencode-npx` |

Both tasks passed the contract checks and touched-script checks: `bash -n`, `shellcheck` and `shfmt -d`.

## Failure and edge-case matrix

| Case | mise | npx | Interpretation |
| --- | --- | --- | --- |
| Missing mise | FAIL clearly | FAIL clearly | Both require mise in the current pilot; the task exits before claiming success. |
| Missing Node | Recovered by mise | Recovered by mise | This is intentional for the pilot, but means “missing runtime” is not a failure if network/bootstrap is available. |
| Network unavailable on clean install | FAIL | FAIL | Neither backend can bootstrap a clean installation without cached artifacts. The runner must preserve the failure and never report verified. |
| Package resolution failure | FAIL | FAIL | Invalid package/version is surfaced by the underlying manager. |
| Version mismatch | FAIL at `verify()` | FAIL at command execution/`verify()` | The postcondition checks actual command output, not merely wrapper existence. |
| Wrapper deleted | FAIL at `verify()` | FAIL at `verify()` | Ownership is observable. |
| Reset refusal | PASS in contract matrix | PASS in contract matrix | Controlled failure injection proves the runner refuses destructive reset without confirmation. |
| Shell initialization absent | PASS | PASS | Verification invokes the wrappers directly in the runner environment; no `.bashrc`, `.zshrc` or `mise activate` is required. |

The npx helper previously performed an unnecessary warm-up command that emitted a `which` usage diagnostic in the Arch container. The warm-up was removed; the remaining diagnostic can still be emitted by npm/npx dependency resolution, but the declared OpenCode command executes and verifies successfully. This is a transparency weakness of the npx backend, not a verification pass condition.

## Decision

Select `mise` as the standard backend for versioned npm CLIs in RaVN.

Reasons:

1. It has explicit ownership of runtime, package, configuration and wrapper.
2. Its state is inspectable through a task-local `mise.toml`.
3. Reset can remove both task state and the exact managed tool entry.
4. It avoids relying on a transient npx environment at every invocation.
5. Its verification and Docker behavior are equivalent or better, while failure output is easier to attribute to the managed installation.

Keep `omarchy-npx-install` as a supported fallback for packages whose distribution requires it. Do not migrate existing tasks automatically. Nix remains a future optional backend candidate and must be evaluated in a separate pilot; this ticket does not make Nix a standard.

## Follow-up risks

- The task requests `allow_builds = true` in its mise tool configuration. Older mise/npm combinations may still require the explicit postinstall fallback; verification remains authoritative.
- The pilots use a fixed version (`1.17.18`) for reproducible tests. A future update policy must distinguish pinned installs from an explicit `latest` policy.
- The failure matrix currently exercises real failures available through missing state and bad resolution, but does not yet inject network failures or reset refusals deterministically. Those belong in a backend-test harness before generalizing the framework.
