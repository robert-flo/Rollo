## Problem Statement

The current RaVN task suite can report that a task completed even when the installed tool is not usable. The primary causes are weak postconditions, ambiguous partial state, implicit runtime assumptions, and insufficient evidence about what was installed. This is especially concerning for npm CLIs, where lifecycle scripts may be required and where `latest` changes over time.

OpenCode is the reference laboratory for solving this reliability problem before the pattern is applied to other tasks. The goal is to establish confidence through repeated, deterministic tests rather than to migrate every existing task.

## Solution

Build and iterate an OpenCode task around one observable lifecycle seam:

`check_state → install/update → lifecycle completion → verify → persist evidence → report status`

Use mise as the standard backend for npm CLIs. Keep mise installation outside this suite for the normal dotfiles environment, while providing an explicit, versioned fallback for Docker/VM tests and an opt-in host fallback. The task must use `latest` only for explicit updates, preserve one previously verified version, verify the candidate before activation, and roll back when possible.

The task runner must distinguish absent, partial, installed, verified, stale, broken, dependency-missing, update-failed, and rollback-failed states. It must never report success based only on an installer exit code, a wrapper existing, or persisted state.

## User Stories

1. As a user, I want OpenCode installed without opening a terminal or TUI, so that it works in `--ALL`, Docker, VM, and dotfiles deployment flows.
2. As a user, I want `run` to install OpenCode when absent, so that a missing task can be recovered through the normal command.
3. As a user, I want `run` to repair partial or broken state, so that stale files never cause the task to be skipped incorrectly.
4. As a user, I want `run` to avoid updating an already verified task, so that ordinary setup is predictable and does not depend on the network.
5. As a user, I want `update` to request the latest OpenCode version explicitly, so that updates are intentional.
6. As a user, I want `check-updates` to inspect available updates without modifying the installation, so that I can decide when to update.
7. As a user, I want Node managed through mise, so that the runtime is consistent across supported Arch environments.
8. As a user, I want the resolved Node and OpenCode versions recorded, so that I can diagnose what was actually installed.
9. As a user, I want the task to run without shell initialization, so that Bash, Zsh, Docker, and non-interactive processes behave consistently.
10. As a user, I want npm lifecycle scripts explicitly enabled for the package when required, so that OpenCode is usable after installation.
11. As a user, I want lifecycle scripts to be covered by verification, so that a skipped postinstall cannot produce a false success.
12. As a user, I want a real OpenCode command execution in `verify`, so that wrapper existence is not treated as proof of installation.
13. As a user, I want the active version to be the only OpenCode command exposed on `PATH`, so that multiple installed versions do not collide.
14. As a user, I want one previously verified version retained for rollback, so that a failed update does not destroy a working installation.
15. As a user, I want a failed update to leave the previous version active, so that the tool remains usable.
16. As a user, I want `rollback_failed` reported explicitly, so that a dangerous recovery failure cannot look like success.
17. As a user, I want reset to remove only resources owned by OpenCode, so that other mise tools and user configuration remain intact.
18. As a user, I want reset followed by verification to prove the task is absent, so that reinstall starts from a known state.
19. As a user, I want reinstall after reset to be tested, so that reset is not merely destructive but actually recoverable.
20. As a user, I want missing mise to produce a clear dependency status, so that the task never fails mysteriously.
21. As a user, I want Docker and VM tests to bootstrap mise through a controlled fallback, so that closed environments can exercise the complete flow.
22. As a user, I want host bootstrap to require explicit opt-in, so that a task never changes system dependencies silently.
23. As a maintainer, I want the mise binary path injectable, so that tests can use fixtures and controlled versions.
24. As a maintainer, I want Docker/VM fixtures to pin mise, so that test results do not change silently with upstream releases.
25. As a maintainer, I want contract tests with controlled dependency doubles, so that deterministic failure paths can be exercised repeatedly.
26. As a maintainer, I want integration tests with real mise, Node, npm, and OpenCode, so that compatibility is proven in a clean environment.
27. As a maintainer, I want manual host validation documented, so that real user-environment assumptions are not hidden.
28. As a maintainer, I want tests to distinguish `PASS`, `FAIL`, `SKIPPED`, `UNSUPPORTED`, and `NOT_RUN`, so that incomplete evidence cannot be mistaken for success.
29. As a maintainer, I want `--all` to fail when any required layer was not executed, so that aggregate success is fail-closed.
30. As a maintainer, I want tests for missing runtime, missing mise, network failure, package-resolution failure, version mismatch, lifecycle failure, partial state, deleted wrapper, and reset refusal, so that the important failure modes are reproducible.
31. As a maintainer, I want every verified result to include structured evidence, so that “completed” can be audited.
32. As a maintainer, I want evidence to include task, operation, versions, state transition, exit codes, verification output, and log paths, so that failures are diagnosable.
33. As a maintainer, I want logs redacted by default, so that tokens and credentials are not persisted accidentally.
34. As a maintainer, I want evidence retention bounded automatically, so that reliability does not create an unbounded maintenance burden.
35. As a maintainer, I want task-specific technical state and runner-level audit results separated, so that the runner does not encode mise internals.
36. As a maintainer, I want legacy tasks isolated from this new contract until migrated individually, so that the OpenCode experiment remains attributable.
37. As a maintainer, I want OpenCode to be the reference implementation, so that later tasks can reuse a proven pattern rather than inventing new lifecycle behavior.

## Implementation Decisions

- mise is the standard backend for versioned npm CLIs in RaVN.
- The existing `omarchy-npx-install` path is not a parallel standard; it remains only for legacy or explicitly justified exceptions.
- mise is normally installed and configured by another dotfiles subsystem. RaVN treats it as an external dependency in the host environment.
- Docker and VM tests may bootstrap a pinned mise fixture automatically. Host bootstrap is opt-in and must never be silent.
- The task must support an injectable mise executable path for controlled tests.
- Node is managed by mise and uses the latest policy for explicit updates; every resolved version is recorded.
- `run` installs or repairs absent, partial, and broken state but does not update a verified installation.
- `check-updates` is read-only and may query the registry.
- `update` is explicit, network-dependent, and transactional.
- Update flow installs a candidate, runs required lifecycle scripts, verifies the candidate, activates it only after verification, and retains one previous verified version.
- A failed update must preserve the previous active version whenever possible. `rollback_failed` is a first-class failure state.
- Only one active wrapper is exposed on `PATH`; older versions remain internal to mise and are not exposed as commands.
- The task contract exposes normalized lifecycle states while task implementations own backend-specific details.
- Persisted task state is advisory. The real filesystem, mise state, and `verify()` have precedence over state files.
- Every `verified` result requires structured evidence and a redacted human-readable log.
- Evidence retention is automatically bounded by age, count, and size; current state and the latest result are always retained.
- `reset` removes task-owned installation state but does not silently erase audit evidence.
- No lifecycle operation opens a terminal, launches a TUI, or requires shell initialization.
- The supported production platform for this increment is Arch Linux.

## Testing Decisions

- The primary test seam is the observable runner lifecycle: state discovery, installation/update, lifecycle completion, verification, evidence persistence, and status reporting.
- Contract tests exercise external behavior using controlled dependency doubles and failure injection; they do not assert private implementation details.
- Integration tests run real mise, Node, npm, and OpenCode in clean Docker environments; a VM is used when Docker cannot represent the required host behavior.
- Manual validation runs the same lifecycle on the real Arch host and records the result separately from automated tests.
- Required lifecycle scenarios include clean install, verified rerun, explicit update, successful activation, failed update, rollback, missing dependencies, network failure, package resolution failure, version mismatch, lifecycle failure, partial state, deleted wrapper, reset refusal, reset verification, reinstall, and no shell initialization.
- Test output distinguishes `PASS`, `FAIL`, `SKIPPED`, `UNSUPPORTED`, and `NOT_RUN`; `--all` fails if a required layer is not executed.
- Every test records mise, Node, npm, requested package policy, resolved package version, operation, state transition, exit codes, verification output, and log location.
- Existing task contract tests, runner tests, ShellCheck, Bash syntax checks, shfmt, and Docker task tests are prior art and remain required gates.
- The test interface must expose contract, integration, and full-matrix modes through the task runner rather than requiring knowledge of internal scripts.

## Out of Scope

- Migrating existing legacy tasks.
- Installing mise as part of the main dotfiles installer in this increment.
- Supporting non-Arch production environments.
- Making Nix or Homebrew a standard backend.
- Maintaining npx as an equivalent backend.
- Interactive authentication or API credential setup.
- Opening a new terminal or TUI after installation.
- Registry security policy beyond basic redaction and the selected mise/npm behavior.
- Implementing a universal backend abstraction before OpenCode proves the lifecycle contract.
- Automatically updating verified tasks during `run`.

## Further Notes

OpenCode is not considered complete because one installation passed. It is complete only when the failure-closed lifecycle, evidence, rollback, and contract/integration/manual test matrix produce repeatable evidence. Only then should the contract be standardized and applied to the next task one at a time.
