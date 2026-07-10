# Canonical `global_fn.sh` Integration Tickets

**Source specification:** Canonical `global_fn.sh` Integration Specification  
**Execution model:** Tracer-bullet vertical slices  
**Review standard:** Review this repository as if you are blocking or approving a production PR.

---

## Delivery Principles

- Each ticket must fit within one fresh implementation context.
- Each completed ticket must leave the canonical helper in a verifiable state.
- Public behavior must remain compatible at every stage.
- The first helper implementation remains the design and architectural authority.
- The second helper implementation contributes capabilities only.
- Prefer the highest available test seam.
- Avoid introducing multiple new test seams.
- Make the change easy, then make the easy change.
- A ticket is complete only when its behavior and compatibility checks pass.

---

## Ticket 1 — Establish the Canonical Helper Architecture

**Blocked by:** None

### What it delivers

A canonical `global_fn.sh` structure that expresses the final design language without changing the behavior of the first implementation.

This ticket:

- establishes the canonical header and file identity;
- defines the final domain-based section order;
- reorganizes the first implementation's existing constants and helpers into those sections;
- standardizes section separators, comments, whitespace, quoting style, and function documentation;
- records the public symbols currently exposed by both implementations;
- introduces or identifies the single public-API compatibility test seam;
- verifies that the reorganized canonical file can still be sourced and used exactly as before.

### End-to-end verification

- Source the reorganized canonical helper.
- Invoke every helper originally present in the first implementation.
- Confirm expected output and return status.
- Confirm the public-surface inventory is available for later tickets.
- Confirm no functionality from the first implementation was lost.

### Notes

This is prefactoring. It makes later integration easy without yet adding the second implementation's missing capabilities.

---

## Ticket 2 — Preserve the Shared Runtime and Package Contract

**Blocked by:** Ticket 1

### What it delivers

A complete vertical slice for project runtime initialization and package querying.

This ticket integrates and modernizes:

- shared directory variables;
- cache and configuration locations;
- package-manager command references;
- supported AUR helper lists;
- supported shell lists;
- installed-package detection;
- package repository availability checks;
- AUR availability checks;
- dynamic selection from a package list.

The integrated behavior must remain available under all existing public names and exports.

### End-to-end verification

- Source the canonical helper in an isolated environment.
- Verify environment overrides are respected.
- Verify expected variables are initialized and exported.
- Stub package-manager commands and validate success and failure behavior.
- Run a representative package-consuming script or compatibility fixture unchanged.

### Compatibility requirements

- No consumer call-site changes.
- Existing argument order remains valid.
- Existing return-code semantics remain valid.
- Dynamic variable assignment and export behavior remain valid.

---

## Ticket 3 — Integrate Hardware Detection and Timed Interaction

**Blocked by:** Ticket 1

### What it delivers

A complete vertical slice for hardware-aware and interactive behavior.

This ticket integrates and modernizes:

- NVIDIA GPU detection;
- verbose detected-GPU output;
- driver lookup behavior;
- timed single-key prompts;
- `/dev/tty` fallback behavior;
- exported prompt input state.

The implementation adopts the canonical documentation and output language while preserving the existing public contract.

### End-to-end verification

- Stub hardware enumeration output and validate NVIDIA detection.
- Validate non-NVIDIA behavior.
- Validate verbose output shape at the public seam.
- Validate driver lookup against controlled fixtures.
- Validate timed prompt behavior in interactive and redirected-input scenarios.
- Confirm `PROMPT_INPUT` remains available as expected.

### Compatibility requirements

- Existing flags remain valid.
- Existing return statuses remain valid.
- Existing data-source assumptions remain supported.
- Prompt timeout must not terminate the parent script unexpectedly.

---

## Ticket 4 — Consolidate Console Output and Logging

**Blocked by:** Ticket 1

### What it delivers

A unified public console and logging subsystem using the canonical visual language.

This ticket:

- preserves the first implementation's header, section, step, success, error, warning, and information helpers;
- integrates the flexible legacy logging helper;
- reconciles color definitions and terminal capability detection;
- defines consistent standard-output and standard-error behavior;
- preserves log-file creation and ANSI-stripping behavior;
- prevents duplicate competing implementations of the same console responsibility.

### End-to-end verification

- Exercise each semantic console helper.
- Exercise every supported logging option used by current scripts.
- Verify terminal and non-terminal behavior.
- Verify log files are created only under the established conditions.
- Verify persisted logs do not contain ANSI escape sequences.
- Run representative logging consumers unchanged.

### Compatibility requirements

- Existing logger option vocabulary remains accepted.
- Existing `RAVN_LOG` and section behavior remains supported.
- Current public print helpers remain available.
- Output modernization must not remove information relied upon by users or scripts.

---

## Ticket 5 — Integrate Status Execution, Spinner, and Retry

**Blocked by:** Ticket 4

### What it delivers

A complete execution-control slice with coherent status output.

This ticket integrates and modernizes:

- animated spinner behavior;
- non-interactive fallback;
- cursor hiding and restoration;
- wrapped command execution;
- dry-run handling;
- `sudo` credential prevalidation;
- command exit-code propagation;
- exponential retry behavior;
- retry diagnostics.

All execution output must reuse the canonical console subsystem from Ticket 4.

### End-to-end verification

- Run a successful background command.
- Run a failing background command.
- Verify non-interactive execution does not animate or hang.
- Verify cursor restoration on normal completion and handled failure.
- Verify dry-run avoids side effects.
- Verify commands passed as argument arrays are preserved.
- Verify retry succeeds after controlled transient failures.
- Verify retry returns failure after exhaustion.

### Compatibility requirements

- Existing helper names and argument order remain valid.
- The wrapped command's final status remains observable.
- `sudo` behavior must not break password prompting.
- Diagnostic output must not obscure the actual failure.

---

## Ticket 6 — Integrate Download and Repository Synchronization

**Blocked by:** Ticket 5

### What it delivers

A complete vertical slice from remote acquisition through local repository state.

This ticket integrates and modernizes:

- `curl` and `wget` download abstraction;
- file and standard-output download modes;
- download status display;
- repository clone behavior;
- existing-repository update behavior;
- remote normalization;
- ref or branch checkout;
- retry integration;
- optional SSH preference;
- HTTPS fallback;
- dry-run behavior;
- canonical success and failure reporting.

### End-to-end verification

- Stub `curl` and validate file and stdout modes.
- Stub `wget` and validate fallback behavior.
- Validate clear failure when no supported downloader exists.
- Clone a controlled local or fixture repository.
- Update an existing controlled repository.
- Validate remote normalization.
- Validate ref selection.
- Validate dry-run produces no repository changes.
- Validate retry integration.
- Validate HTTPS fallback when SSH is unavailable.

### Compatibility requirements

- Existing helper names and arguments remain valid.
- Existing consumers do not need modification.
- Potentially destructive reset behavior must remain explicit and documented.
- Command failures must return non-zero status reliably.

---

## Ticket 7 — Integrate Installation Statistics and Summary Reporting

**Blocked by:** Ticket 4

### What it delivers

A complete result-tracking and reporting slice.

This ticket integrates and modernizes:

- successful-operation counters;
- failed-operation counters;
- skipped-operation counters;
- associated item lists;
- compact item-list rendering;
- wrapped rendering for larger lists;
- final summary dashboard;
- canonical styling and terminal degradation.

### End-to-end verification

- Record successful, failed, and skipped items.
- Verify numerical totals.
- Verify empty-list behavior.
- Verify compact rendering for small sets.
- Verify wrapped rendering for large sets.
- Verify summary output in terminal and non-terminal contexts.
- Run a representative summary consumer unchanged.

### Compatibility requirements

- Existing counter variable names remain available where publicly consumed.
- Existing count helpers retain their semantics.
- The summary helper's label behavior remains supported.
- Rendering changes must not alter the underlying result data.

---

## Ticket 8 — Production Compatibility Review and Canonical Cutover

**Blocked by:** Tickets 2, 3, 4, 5, 6, and 7

### What it delivers

The production approval gate and final canonical cutover.

This ticket:

- compares the public surface of both original implementations against the integrated canonical helper;
- verifies that every required public symbol remains available;
- removes any duplicate or transitional implementation that is no longer necessary;
- reviews compatibility wrappers and retains only those required for consumers;
- runs Bash syntax validation;
- runs ShellCheck under the repository's accepted policy;
- runs public-API tests;
- runs representative consumer scripts or fixtures unchanged;
- reviews terminal safety, quoting, local scoping, error handling, and logging;
- confirms the canonical file reads as the work of one author;
- documents any intentionally retained legacy behavior;
- marks the older competing implementation as replaceable or removable according to repository policy.

### End-to-end verification

- Source the final canonical helper in a clean shell.
- Execute the full public-API compatibility suite.
- Execute representative package, interaction, logging, execution, download, repository, and summary consumers.
- Confirm no call-site edits are needed.
- Confirm no required public symbol is missing.
- Confirm no duplicate public implementation remains.
- Confirm static analysis passes or has reviewed, documented exceptions.

### Approval criteria

The ticket is complete only when a reviewer can approve the integration as a production PR without requesting structural changes.

---

## Dependency Graph

```text
T1  Establish canonical architecture
├── T2  Shared runtime and package contract
├── T3  Hardware detection and timed interaction
└── T4  Console output and logging
    ├── T5  Status execution, spinner, and retry
    │   └── T6  Download and repository synchronization
    └── T7  Installation statistics and summary

T2 + T3 + T4 + T5 + T6 + T7
                │
                ▼
T8  Production compatibility review and canonical cutover
```

---

## Completion Order

A safe default sequence is:

1. Ticket 1
2. Ticket 4
3. Ticket 2
4. Ticket 3
5. Ticket 5
6. Ticket 7
7. Ticket 6
8. Ticket 8

Tickets 2 and 3 may run in parallel after Ticket 1.

Ticket 7 may run in parallel with Tickets 5 and 6 after Ticket 4.

Ticket 8 cannot begin until every integration ticket is complete.

---

## Definition of Done for Every Ticket

Every ticket must:

- preserve the public contract it touches;
- include or update behavior-focused tests;
- leave the canonical helper sourceable;
- avoid requiring unrelated consumer edits;
- use the canonical design language;
- pass applicable syntax and static checks;
- document any compatibility compromise;
- remain small enough to review in one fresh context;
- be demoable or independently verifiable;
- meet the production PR review standard.
