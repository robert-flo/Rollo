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
