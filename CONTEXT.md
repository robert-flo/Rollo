# Global Helper Integration Context

This context defines the shared language for consolidating the repository's global shell helpers while preserving the behavior relied upon by existing installation flows.

## Helper Implementations

**Canonical helper**:
The `Configs/.local/bin/global_fn.sh` implementation that owns the target architecture, visual language, and final organization.
_Avoid_: new helper, preferred helper

**Baseline helper**:
The unchanged `Scripts/global_fn.sh` implementation used as the compatibility reference during side-by-side validation.
_Avoid_: old helper, secondary helper

**Semantic equivalence**:
Preservation of the same observable events, ordering, return statuses, exported state, simulated effects, warnings, and errors, while allowing intentional visual differences.
_Avoid_: textual equality, identical output

**Side-by-side validation**:
Running the baseline helper and canonical helper through equivalent dry-run scenarios under controlled conditions so their semantic behavior can be compared directly.
_Avoid_: manual comparison, visual test only

**Sandboxed comparison**:
A side-by-side validation run whose helpers, script copies, home directory, caches, bare repositories, and worktrees are isolated in a temporary directory.
_Avoid_: live test, direct system test

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

**Task menu**:
The interactive entrypoint for inspecting, selecting, executing, testing, and resetting tasks; it is an orchestration surface, not an installable task.
_Avoid_: task module, baseline installer

**Baseline mode**:
The explicit non-interactive execution mode used by the dotfiles installer to run only baseline tasks.
_Avoid_: interactive setup, full setup
