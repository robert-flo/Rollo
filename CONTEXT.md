# Global Helper Integration Context

This context defines the shared language for consolidating the repository's global shell helpers while preserving the behavior relied upon by existing installation flows.

## Helper Implementations

**Canonical helper**:
The `Configs/.local/bin/global_fn.sh` implementation that owns the target architecture, visual language, and final organization.
_Avoid_: new helper, preferred helper

**Baseline helper**:
The unchanged `Scripts/global_fn.sh` implementation used as the compatibility reference during side-by-side validation.
_Avoid_: old helper, secondary helper

**Baseline implementation**:
The unchanged legacy installation flow used as the behavioral reference during migration.
_Avoid_: old script, deprecated implementation

**Candidate implementation**:
The new RaVN task flow evaluated against the baseline implementation before it is allowed to replace the legacy integration.
_Avoid_: replacement script, experimental script

**Migration orchestrator**:
The first candidate task that coordinates the complete dotfiles installation flow end to end while preserving explicit stage boundaries for later extraction.
_Avoid_: package task, monolithic script

**Stage boundary**:
An observable transition in the installation flow with declared inputs, outputs, authority, failure behavior, and verification evidence.
_Avoid_: arbitrary function, shell section

**Semantic equivalence**:
Preservation of the same observable events, ordering, return statuses, exported state, simulated effects, warnings, and errors, while allowing intentional visual differences.
_Avoid_: textual equality, identical output

**Side-by-side validation**:
Running the baseline helper and canonical helper through equivalent dry-run scenarios under controlled conditions so their semantic behavior can be compared directly.
_Avoid_: manual comparison, visual test only

**Sandboxed comparison**:
A side-by-side validation run whose helpers, script copies, home directory, caches, bare repositories, and worktrees are isolated in a temporary directory.
_Avoid_: live test, direct system test

**Visual-equivalence exception**:
A deliberate difference in banners, colors, spacing, wording, timestamps, or other presentation details that does not change semantic behavior.
_Avoid_: tolerated regression, output mismatch

## Scope Boundaries

**Visual integration phase**:
The current phase, focused on presenting all retained helper behavior through one modern, coherent visual and structural language without changing consumer contracts.
_Avoid_: complete refactor, consumer migration

**Consumer modernization phase**:
A later phase that refactors the scripts using the helper, including broader logical cleanup and ShellCheck remediation.
_Avoid_: current phase, helper integration

## RaVN Task Execution

**Dotfiles installer**:
The reproducible, non-interactive flow that installs and configures the dotfiles and only the tasks required for that baseline.
_Avoid_: task runner, optional bootstrap

**Task runner**:
The independent interface for selecting, launching, and verifying individual RaVN tasks outside the dotfiles installer.
_Avoid_: dotfiles installer, pipeline

**Baseline task**:
A task required to establish the supported dotfiles environment and therefore eligible to run from the dotfiles installer.
_Avoid_: optional task

**Optional task**:
A task for an additional CLI, npm tool, application, or administrative action that can be run independently without being required by the dotfiles baseline.
_Avoid_: baseline task

**Task verification**:
The explicit check of a task's postcondition after execution; a task is successful only when its verification passes.
_Avoid_: pre-check, attempted installation

**Task family**:
A group of tasks sharing the same responsibility and validation strategy, such as baseline configuration, CLI tools, desktop applications, or system administration.
_Avoid_: all tasks, package list

**Task reset**:
The explicit, task-owned operation that removes a task's installation and configuration so it can be run again from a clean state.
_Avoid_: cleanup, cache clearing, generic uninstall

**Installer strategy**:
The task-specific mechanism used to install and manage a tool, such as pacman, npm, mise, Homebrew, Flatpak, or an upstream installer.
_Avoid_: framework-wide package manager

**Upstream installer backend**:
The shared task backend for tools installed by a vendor-provided remote installer rather than a package manager, with explicit download, execution, verification, and evidence boundaries.
_Avoid_: curl task, remote script, generic installer

**User-level installation**:
An installation whose files, executable, configuration, and reset scope belong to one user under user-owned directories rather than system-wide locations.
_Avoid_: global installation, system install

**Task menu**:
The interactive entrypoint for inspecting, selecting, executing, testing, and resetting tasks; it is an orchestration surface, not an installable task.
_Avoid_: task module, baseline installer

**Baseline mode**:
The explicit non-interactive execution mode used by the dotfiles installer to run only baseline tasks.
_Avoid_: interactive setup, full setup

## Administrative Task Execution

**Suite**:
The single RaVN execution surface responsible for installing user tools,
system packages, and host configuration.
_Avoid_: installer, package manager, dotfiles script

**Task**:
An independently executable unit of desired system state with declared
ownership, dependencies, permissions, and observable verification.
_Avoid_: script, step, command

**Execution profile**:
A task's declared operational boundary, such as user-tool, system-package,
system-config, service, network-security, or privileged orchestration.
_Avoid_: task type, category

**Postcondition**:
An observable fact that must be true after a task succeeds; task success is not
accepted from process exit status alone.
_Avoid_: success message, install result

**Privileged task**:
A task that requires elevated authority to inspect or change system-owned
resources.
_Avoid_: sudo task, root script

**Ownership boundary**:
The explicit set of files, packages, services, accounts, rules, or other
resources a task may create, modify, preserve, or remove.
_Avoid_: scope, side effects

**Plan**:
A read-only description of the tasks, dependencies, permissions, resources,
and postconditions that an execution would attempt.
_Avoid_: dry-run output, preview log

**Apply**:
The authorized phase that executes a previously reviewed plan and records its
outcomes.
_Avoid_: install, run

**Verification**:
The explicit observation of a task's postconditions after execution.
_Avoid_: exit-code check, success message

**VM adapter**:
A future test adapter that runs tasks or complete revisions inside a virtual
machine; it is outside the current suite-scope design increment.
_Avoid_: Docker replacement, VM mode

**RavnVM development session**:
A developer-controlled QEMU/KVM environment provisioned to inspect and test one specified RaVN branch or commit, with optional persistence for interactive investigation.
_Avoid_: task runner, CI runner, generic scenario runner

**Test revision**:
The exact RaVN branch or commit selected as the subject of a RavnVM development session.
_Avoid_: latest code, current checkout

**Pre-integration validation**:
The developer practice of exercising a feature branch or commit in RavnVM so its behavior can be inspected before the change is integrated into `dev`.
_Avoid_: CI approval, post-merge testing

**RavnVM interactive menu**:
The no-argument user interface for selecting an existing RavnVM operation while preserving direct invocation through the current positional arguments and flags.
_Avoid_: replacement CLI, task menu, scenario runner

**RavnVM interaction surface**:
An entrypoint through which a developer starts or inspects a RavnVM development session: direct CLI invocation, the interactive menu, or the repository's `make` development targets.
_Avoid_: separate VM implementation, task runner

**Make VM interface**:
The existing `make/dev.mk` targets that expose RavnVM operations through `make`, including branch/commit selection via `REF`, resource overrides, persistence, dry-run, snapshot management, dependency setup, and disk inspection.
_Avoid_: make backend, alternate VM engine

**Graceful abort**:
The controlled termination of the current RavnVM operation after an error or edge case, preserving diagnostic evidence, cleaning up owned temporary resources, and returning control without hiding the failure.
_Avoid_: silent recovery, forced exit, best-effort continuation

**Activation boundary**:
The event or action required before an applied change becomes effective, such
as a reboot, new login session, daemon reload, or network reconnection.
_Avoid_: side effect, delayed success

**Pending activation**:
The state where a task's changes were applied and recorded, but its effective
postconditions cannot be confirmed until the activation boundary is crossed.
_Avoid_: partial failure, success anyway

**Reconciliation report**:
The user-facing summary of what a task attempted, what was verified, what was
not achieved, and what action remains necessary.
_Avoid_: install log, terminal output

**Applied-pending-activation**:
A normalized task outcome meaning the declared changes were applied, but an
activation boundary must be crossed before all effective postconditions can be
verified.
_Avoid_: verified, failed

**Partially-verified**:
A normalized task outcome meaning some declared postconditions are true while
others remain false, unknown, or blocked by the environment.
_Avoid_: success, warning only

**Reversibility policy**:
The declared recovery capability of a task: reversible, compensatable,
irreversible, or none.
_Avoid_: rollback guarantee, undo support

**Resource ownership**:
The authority a task has over a declared system resource and the boundary that
prevents unrelated tasks from silently overwriting it.
_Avoid_: file list, side effects

**Resource conflict**:
An incompatible claim by two tasks over the same system resource or state
boundary, requiring explicit coordination before apply.
_Avoid_: duplicate task, ordering issue

**Reference task**:
The first fully validated canonical task for an execution profile, whose
contract and tests become the template for later migrations in that profile.
_Avoid_: generic template, example script

**Managed section**:
A bounded portion of a shared resource that a task owns while preserving
unmanaged content around it.
_Avoid_: managed file, whole-file ownership

**Reference contract**:
The complete set of permissions, ownership rules, postconditions, evidence,
activation behavior, and recovery guarantees demonstrated by a reference task.
_Avoid_: implementation template, helper function

**Effective configuration**:
The behavior a system parser or service resolves from the combined resource,
not merely the text a task wrote to disk.
_Avoid_: file contents, desired text

**Administrative test harness**:
The test runner and fixtures that validate administrative tasks, their resource
ownership, postconditions, activation boundaries, and reconciliation outcomes.
_Avoid_: package test, generic test runner

**Testability contract**:
The minimum task metadata and executable checks required for a task to produce
reproducible evidence; a task is incomplete without it.
_Avoid_: test script, smoke test

**Administrative task contract**:
The shared declaration and lifecycle hooks that define a task's profile,
permissions, ownership, desired changes, postconditions, evidence, activation
boundary, and recovery behavior.

**Task runner visual language**:
The shared presentation language for RaVN task interfaces: the RAVN brand,
single-author byline, global Nerd Font icon catalog, global color palette,
semantic status helpers, English user-facing copy, and consistent section and
selector structure.
_Avoid_: local palette, script-specific visual language, decorative redesign.

**Modern selector**:
The gum-backed interactive selector used by the task menu when an interactive
TTY and the required dependencies are available.
_Avoid_: gum as a replacement for task execution logic, numbered gum menu.

**Bash fallback**:
The numbered, global-helper-based selector used when `RAVN_UI=bash` is set or
the terminal cannot support the modern selector contract.
_Avoid_: degraded output, legacy interface.

**UI mode**:
The explicit `RAVN_UI` choice controlling interactive presentation: `auto`,
`gum`, or `bash`.
_Avoid_: font detection, selector backend, execution mode.

**Interactive dependency preflight**:
The Arch-only validation and conditional installation of `git`, `curl`, and
`gum` that completes before the task runner presents any interactive UI.
_Avoid_: task verification, per-task dependency check.

**Task selector item**:
The user-visible representation of a discovered task, composed of its semantic
Nerd Font icon, task name, and task family/category.
_Avoid_: raw task filename, menu action.
_Avoid_: legacy task shape, install script

**Read-only plan**:
A plan phase that may inspect and calculate changes but cannot mutate resources,
install packages, restart services, or alter permissions.
_Avoid_: dry-run apply, simulated install

**Capability**:
An explicitly declared authority to perform a class of mutation, such as
writing a managed section, installing a package, managing a service, or using
privileged system commands.
_Avoid_: permission, sudo access

**Fail-closed batch**:
A batch execution policy that stops dependent work after a privileged failure,
preserves the failure in the global result, and requires explicit authorization
to continue with independent tasks.
_Avoid_: best-effort install, ignore errors
