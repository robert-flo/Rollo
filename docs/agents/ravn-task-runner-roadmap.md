# RaVN Task Runner — Agreed Route

This document records the decisions reached during the design session. Future agents must follow this route and must not invent a different architecture or skip directly to implementation.

## Current status

- Design session completed.
- Spec published as GitHub issue [#16](https://github.com/robert-flo/Rollo/issues/16).
- Implementation tickets published as [#17](https://github.com/robert-flo/Rollo/issues/17) through [#22](https://github.com/robert-flo/Rollo/issues/22), with native blocking dependencies.
- No implementation has started.

## Agreed architecture

RaVN has two execution surfaces:

1. The dotfiles installer: reproducible, non-interactive, and limited to baseline tasks.
2. The task menu/runner: manually invoked for optional CLI tools, desktop applications, and system administration.

`setup.sh` remains the public entrypoint. Direct manual execution opens the menu. `install.sh` must invoke an explicit non-interactive baseline mode and must never block on a menu.

Task families are:

- `baseline`
- `cli-tools`
- `desktop-apps`
- `system-admin`

Every new task must declare its identity, family, installer strategy, test level, dependencies, and interactivity. It must implement `check()`, `install()`, and `verify()`. Reset support requires both `reset()` and `verify_reset()`; the runner must never infer uninstall behavior.

`check()` only determines whether a task is already satisfied. `verify()` is the postcondition check that permits a successful result.

## First increment: menu and runner

Implement the tickets in dependency order:

1. #17 — Establish task metadata and runner state contract.
2. #18 — Implement direct verify and run actions.
3. #19 — Add explicit non-interactive baseline mode.
4. #20 — Build the interactive `setup.sh` task menu.
5. #21 — Integrate intuitive task testing.
6. #22 — Add safe explicit task reset.

The menu is inspired by `Scripts/git-setup` and must provide:

1. Verify current configuration
2. Run setup — explicit `ALL` or manual task selection
3. Run integration test — explicit `ALL` or manual task selection
4. Reset selected tasks — only tasks supporting `reset()` and `verify_reset()`
5. Exit

The first increment must preserve compatibility diagnostics for existing legacy tasks. It must not attempt to repair or migrate all existing tasks.

## Required workflow after the first increment

After all six tickets are implemented:

1. Run the production-level `code-review` skill with the literal framing: `Review this repository as if you are blocking or approving a production PR.`
2. Resolve review findings.
3. Run ShellCheck, shfmt, syntax checks, baseline-mode checks, and Docker/VM validation.
4. Commit atomically on a topic branch, push it, and open a PR into `dev`.
5. Do not begin broad task migration before this PR is reviewed and merged.

## Next increment: OpenCode pilot

The OpenCode pilot was completed through tickets #24–#27. The comparison is documented in `docs/agents/opencode-backend-comparison.md` and ADR 0003.

The pilot must compare two strategies under equivalent scenarios:

- `mise` as the selected standard for versioned npm CLIs.
- A hardened `omarchy-npx-install` backend as an explicit fallback.

The comparison must cover clean installation, idempotent rerun, real command execution, missing dependencies, network failure behavior, isolated Docker/VM testing, reset, post-reset verification, and reinstall.

Do not migrate all existing tasks at once. Each task has its own particularities and must be addressed individually using the pilot contract. Nix remains a separate future backend experiment, not a current default.

## Explicitly rejected directions

- Do not keep all optional applications and administrative tasks inside the dotfiles installer.
- Do not open TUIs or new terminals during automated dotfiles deployment.
- Do not use Homebrew as an automatic fallback or standard backend.
- Do not claim success from an installer exit status without `verify()`.
- Do not infer reset/uninstall behavior from `install()` or `cleanup()`.
- Do not repair or migrate every existing task as part of the first menu increment.
- Do not implement before the ticket's spec and acceptance criteria are being followed.
