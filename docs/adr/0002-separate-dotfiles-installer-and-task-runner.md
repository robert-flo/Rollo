# ADR-0002: Separate the dotfiles installer from the task runner

## Status

Accepted

## Context

RaVN tasks currently mix dotfiles deployment, optional CLI/bootstrap installation, administrative changes, and interactive behavior in one pipeline. This makes failures difficult to diagnose, task selection unclear, and successful completion unreliable when a task's postcondition is not actually verified.

## Decision

RaVN will have two execution surfaces:

1. The **dotfiles installer**, which remains reproducible and non-interactive and runs only baseline tasks.
2. The **task runner**, which runs independently and lets the user select, launch, and verify individual optional or administrative tasks.

Optional tasks must not be required for the dotfiles installer to complete successfully.

## Consequences

- The task system needs an explicit distinction between baseline and optional tasks.
- Each task needs a reliable verification contract before it can report success.
- A manual selection interface can support interactive workflows without contaminating the dotfiles deployment flow.

## Task boundaries and reset

Tasks will be segmented into task families with appropriate verification and testing strategies. The framework will not assume that all tasks are package-manager installations; each task may select its own installer strategy.

Reset is task-owned. A task may expose `reset()` and `verify_reset()` to support clean reinstallation. The runner must not infer an uninstall procedure from `install()` or from `cleanup()`.
- Some existing tasks will need to be reclassified or split.

## Entry point

`setup.sh` will become the task menu's user-facing entrypoint while retaining an explicit non-interactive baseline mode for calls from `install.sh`. Direct manual execution opens the menu; automated dotfiles deployment must pass baseline mode explicitly and must never block on interactive input.

The completed implementation route and approved OpenCode reference pattern are recorded in `docs/agents/ravn-task-runner-roadmap.md`.

## Verification rule

Every task must expose a `verify()` operation that checks its postcondition after `install()` completes. `check()` is only for determining whether a task is already satisfied and may be skipped. A task without `verify()` cannot report a verified success.
