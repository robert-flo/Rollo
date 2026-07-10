# Canonical `global_fn.sh` Integration Specification

**Status:** Ready for Agent  
**Triage label:** `ready-for-agent`  
**Review standard:** Review this repository as if you are blocking or approving a production PR.

---

## Problem Statement

The repository currently contains two global helper implementations that cover overlapping responsibilities but represent different stages in the evolution of the project.

The first helper implementation is the closest expression of the desired design language. It establishes the visual identity, structural conventions, naming style, documentation tone, and overall engineering direction that should define the repository going forward.

The second helper implementation contains substantial functionality that is already reused by multiple scripts throughout the codebase. Removing or renaming that functionality would break existing consumers. However, its organization, comments, naming conventions, output style, and internal implementation patterns reflect earlier development stages and no longer align with the desired identity of the project.

From the project owner's perspective, this creates several problems:

- The repository does not look like the work of a single author.
- Shared utilities appear to have been accumulated rather than intentionally designed.
- Similar responsibilities use different visual and implementation conventions.
- Maintainers cannot immediately determine which helper implementation is canonical.
- Refactoring risks breaking existing scripts because the older implementation contains public behavior relied on throughout the repository.
- Future additions could continue the inconsistency if there is no clearly defined source of truth.
- The codebase looks older and less cared for than the quality of its actual functionality warrants.

The project needs a single canonical global helper framework that preserves all existing behavior while adopting the design language of the first implementation across every capability currently supplied by the second.

This is not a mechanical file merge. It is an architectural consolidation and compatibility-preserving modernization.

---

## Solution

Promote the first `global_fn.sh` implementation as the canonical source of truth for the helper framework.

Semantically integrate every required capability from the second implementation into the first. The first implementation defines the architecture, identity, visual language, organization, and coding conventions. The second implementation contributes functionality only.

For every capability found in the second implementation:

1. Determine whether the first implementation already provides the same responsibility.
2. Preserve the first implementation when it already fully satisfies the contract.
3. Improve the canonical implementation when the second provides a clear robustness or completeness advantage.
4. Add missing capabilities only after adapting them to the canonical design language.
5. Consolidate overlapping behavior instead of duplicating it.
6. Preserve compatibility through stable public names, arguments, exports, return values, side effects, and output behavior where consumers depend on them.
7. Use aliases or compatibility wrappers only when they are necessary to prevent breakage, not as a substitute for proper integration.

The resulting helper framework must:

- remain compatible with every current consumer;
- expose all functionality currently relied upon by the repository;
- be organized by functional domain;
- present one consistent visual and documentation style;
- appear to have been written by one author through natural evolution;
- pass a production-grade review for correctness, maintainability, and robustness.

No downstream script should require modification merely because the canonical helper implementation replaces the older one.

---

## User Stories

1. As the project owner, I want one canonical helper implementation, so that there is no ambiguity about where shared functionality belongs.
2. As the project owner, I want the repository to look like the work of one author, so that it reflects a coherent engineering identity.
3. As the project owner, I want the modern design language applied to all shared helpers, so that the software no longer looks old or neglected.
4. As the project owner, I want existing behavior preserved, so that modernization does not introduce regressions.
5. As a maintainer, I want all existing scripts to keep working unchanged, so that the integration can be adopted safely.
6. As a maintainer, I want public helper names preserved, so that current call sites remain valid.
7. As a maintainer, I want helper arguments preserved, so that scripts continue invoking them correctly.
8. As a maintainer, I want helper return codes preserved, so that conditional execution remains correct.
9. As a maintainer, I want exported variables preserved, so that environment-dependent scripts do not break.
10. As a maintainer, I want observable side effects preserved, so that installation and configuration flows remain stable.
11. As a maintainer, I want shared variables initialized predictably, so that consumers have a stable runtime environment.
12. As a maintainer, I want helpers grouped by domain, so that I can locate functionality quickly.
13. As a maintainer, I want comments and documentation to follow one convention, so that the file is easy to read and extend.
14. As a maintainer, I want duplicated responsibilities consolidated, so that future fixes are made in one place.
15. As a maintainer, I want implementation details modernized when safe, so that the framework becomes more robust without breaking callers.
16. As a maintainer, I want defensive Bash practices used consistently, so that failures are predictable and diagnosable.
17. As a maintainer, I want variables quoted correctly, so that paths and arguments containing whitespace behave safely.
18. As a maintainer, I want local variables scoped consistently, so that helpers do not accidentally pollute shared state.
19. As a maintainer, I want terminal-dependent behavior to degrade gracefully, so that non-interactive execution remains reliable.
20. As a maintainer, I want colors disabled or degraded safely when terminal capabilities are unavailable, so that logs remain readable.
21. As a maintainer, I want log files generated consistently, so that troubleshooting remains straightforward.
22. As a maintainer, I want logging behavior preserved for existing consumers, so that scripts do not lose diagnostics.
23. As a maintainer, I want package detection helpers preserved, so that installation decisions remain correct.
24. As a maintainer, I want repository package availability checks preserved, so that installers continue resolving packages correctly.
25. As a maintainer, I want AUR availability checks preserved, so that Arch-specific installation flows remain intact.
26. As a maintainer, I want dynamic package-list detection preserved, so that existing selection logic keeps working.
27. As a maintainer, I want GPU detection preserved, so that hardware-specific installation logic remains correct.
28. As a maintainer, I want NVIDIA driver lookup preserved, so that driver recommendations continue working.
29. As a maintainer, I want timed prompts preserved, so that unattended and interactive flows continue behaving as expected.
30. As a maintainer, I want timed prompts to work with `/dev/tty` when available, so that redirected input does not break interaction.
31. As a maintainer, I want command existence checks available, so that scripts can safely branch on dependencies.
32. As a user, I want headers, sections, steps, warnings, errors, and success messages to share one visual language, so that the software feels cohesive.
33. As a user, I want status messages to be readable in interactive terminals, so that installation progress is easy to follow.
34. As a user, I want output to remain usable in non-interactive environments, so that automation and logs are not corrupted by terminal effects.
35. As a user, I want spinners to indicate long-running work, so that the software feels responsive.
36. As a user, I want spinners to restore the cursor reliably, so that failed or interrupted operations do not leave the terminal in a broken state.
37. As a user, I want dry-run behavior preserved, so that I can inspect planned operations safely.
38. As a user, I want commands requiring `sudo` to avoid conflicting with spinner output, so that password prompts remain usable.
39. As a user, I want transient commands retried with backoff, so that temporary network failures do not immediately abort installation.
40. As a maintainer, I want retry behavior to preserve the wrapped command's final success or failure, so that callers can respond correctly.
41. As a user, I want downloads to work through either `curl` or `wget`, so that the framework does not depend unnecessarily on one downloader.
42. As a user, I want download failures to produce meaningful errors, so that missing prerequisites are obvious.
43. As a user, I want downloads optionally shown through a status indicator, so that the interface remains modern and informative.
44. As a maintainer, I want repository clone and update behavior centralized, so that scripts do not duplicate Git synchronization logic.
45. As a maintainer, I want existing repositories updated safely, so that rerunning setup remains idempotent.
46. As a maintainer, I want remote URLs normalized when repositories already exist, so that configuration drift is corrected.
47. As a maintainer, I want HTTPS to remain a safe fallback, so that repository setup works without SSH credentials.
48. As a maintainer, I want SSH used when explicitly preferred and demonstrably available, so that authenticated workflows remain convenient.
49. As a maintainer, I want branch or ref selection preserved, so that consumers synchronize the intended revision.
50. As a maintainer, I want failed repository synchronization reported clearly, so that installation does not silently continue in an invalid state.
51. As a maintainer, I want installation result counters preserved, so that scripts can produce accurate completion summaries.
52. As a maintainer, I want successful, failed, and skipped item lists preserved, so that users can understand what happened.
53. As a user, I want concise summaries for small item sets, so that output is easy to scan.
54. As a user, I want wrapped summaries for large item sets, so that output remains readable.
55. As a user, I want the final dashboard to use the canonical visual language, so that the installation experience feels unified.
56. As a reviewer, I want each helper to have a clear responsibility, so that the implementation is maintainable.
57. As a reviewer, I want no unnecessary compatibility duplication, so that technical debt is not disguised as safety.
58. As a reviewer, I want ShellCheck findings resolved or explicitly justified, so that common shell defects are prevented.
59. As a reviewer, I want syntax validation performed, so that the canonical helper can be sourced safely.
60. As a reviewer, I want tests to exercise public behavior rather than internal implementation, so that refactoring remains possible.
61. As a reviewer, I want representative consumer scripts used as compatibility checks, so that real integration risks are covered.
62. As a reviewer, I want the highest practical test seam used, so that tests validate the behavior users and scripts actually depend on.
63. As a contributor, I want a predictable section structure, so that new helpers are placed consistently.
64. As a contributor, I want a single documentation voice, so that new code naturally follows the established identity.
65. As a contributor, I want one naming philosophy for local variables and functions, so that the framework is easy to learn.
66. As a contributor, I want error-handling conventions documented by example, so that new helpers fail consistently.
67. As a future maintainer, I want the legacy implementation to become unnecessary, so that the repository does not retain competing sources of truth.
68. As a future maintainer, I want the migration to be invisible to consumers, so that internal improvement does not create downstream work.
69. As a future maintainer, I want the canonical helper to support continued evolution, so that new features do not recreate past inconsistency.
70. As the project owner, I want the final result to be approvable as a production PR, so that quality is measured by engineering standards rather than by whether the script merely runs.

---

## Implementation Decisions

### 1. Canonical source of truth

The first helper implementation is the canonical source of truth.

It defines:

- the file's identity;
- section layout;
- visual language;
- documentation tone;
- naming conventions;
- formatting conventions;
- preferred implementation style.

The second implementation does not define architecture. It supplies behavior that must be evaluated and adapted.

### 2. Compatibility is non-negotiable

The integration must preserve every public contract currently relied upon by repository scripts.

The compatibility surface includes:

- function names;
- function arguments;
- default argument behavior;
- return codes;
- exported variables;
- global variables intentionally consumed by callers;
- environment variable interaction;
- standard output and standard error where callers or users depend on them;
- filesystem side effects;
- process execution behavior;
- dry-run behavior;
- interactive behavior;
- logging behavior.

A change that may break an existing consumer must be treated as blocking until compatibility is demonstrated.

### 3. Semantic integration

Capabilities are not copied mechanically.

Each capability from the second implementation must be classified as:

- already represented by the canonical implementation;
- partially represented and suitable for enhancement;
- missing and requiring integration;
- duplicated and requiring consolidation;
- obsolete or unsafe and requiring compatibility-preserving replacement.

The final implementation should appear designed rather than merged.

### 4. Domain-based organization

The canonical helper framework will be organized by responsibility.

The intended domain structure is:

1. Colors & Styling
2. Global Variables
3. Core Helpers
4. Console Output
5. Logging
6. Package Management
7. Hardware Detection
8. Interactive Utilities
9. Execution Helpers
10. Download Helpers
11. Repository Helpers
12. Installation Statistics
13. Summary & Reporting

Sections may be refined during implementation if the final structure remains coherent and avoids fragmentation.

### 5. One-author identity

All integrated functionality must adopt one voice.

This includes:

- header design;
- section separators;
- comment format;
- function documentation;
- naming style;
- indentation;
- conditionals;
- `case` formatting;
- use of `local`;
- quoting;
- error messages;
- status messages;
- color and icon choices.

A reviewer should not be able to infer which implementation a helper came from.

### 6. Public names remain stable

Existing function names are preserved, including older names that remain part of the public contract.

Modern semantic helpers may coexist with compatibility names when necessary, but duplicate implementations must not be maintained.

When two names represent the same responsibility, one canonical implementation should serve both through a lightweight compatibility layer where safe.

### 7. Global runtime variables remain available

Shared directory variables, package manager command references, supported helper lists, and other exported values used by current scripts must remain available under their current names.

Initialization must remain compatible with the current project runtime assumptions, including environment-variable overrides.

### 8. Package and system helpers remain Arch-aware

The canonical framework remains a project-level shared library rather than a platform-agnostic generic utility package.

Arch Linux, AUR, pacman, HyDE, RaVN, and project-specific behavior may remain in the canonical file because those capabilities are reused across multiple scripts.

This scope is intentional.

### 9. Console output is a unified subsystem

Header, section, step, informational, warning, error, and success output must use the canonical visual language.

Terminal capabilities must degrade gracefully.

Non-interactive execution must avoid corrupt control sequences where practical.

### 10. Existing logging contracts are preserved

The flexible logging helper remains available with its current option vocabulary and log-file behavior.

Its internals may be reorganized and documented, but existing invocations must remain valid.

Logging output should align visually with the canonical framework without changing semantics relied upon by consumers.

### 11. Execution helpers are robust

Spinner, status execution, retry, and dry-run behavior must be integrated as one coherent execution subsystem.

The implementation must account for:

- interactive and non-interactive terminals;
- cursor restoration;
- subprocess exit status;
- `sudo` credential prompts;
- commands passed as argument arrays;
- retry exhaustion;
- meaningful diagnostics.

### 12. Download abstraction remains dual-backend

The downloader helper must continue supporting `curl` and `wget`.

The implementation should prefer the first available supported downloader and fail clearly if neither exists.

Download-with-status behavior must reuse the canonical execution/status subsystem rather than duplicate animation logic.

### 13. Repository synchronization is centralized

Clone and update behavior remains available as a shared helper.

It must preserve:

- existing repository detection;
- remote URL normalization;
- branch or ref selection;
- retry behavior;
- optional SSH preference;
- HTTPS fallback;
- dry-run behavior;
- success and failure reporting.

Potentially destructive synchronization behavior must be documented and reviewed carefully because it can reset local repository state.

### 14. Statistics remain stateful and compatible

Installation counters and item lists remain available under their current names.

Counter helpers must continue recording successful, failed, and skipped operations.

Summary rendering may be adapted to the canonical visual language while preserving the data contract.

### 15. No consumer migration is required

The intended adoption mechanism is replacement of the older shared helper with the canonical integrated implementation.

Consumer scripts should not require edits as a prerequisite for this work.

Consumer cleanup or migration may be proposed later as separate work, but it is not part of this specification.

### 16. Production PR quality gate

The completed work must be reviewed as if it were a production Pull Request.

Approval requires:

- syntax correctness;
- ShellCheck review;
- consistent quoting;
- controlled global state;
- predictable error handling;
- terminal safety;
- compatibility evidence;
- absence of avoidable duplication;
- coherent architecture;
- clear documentation;
- no unexplained behavioral change.

---

## Testing Decisions

### Primary test seam

The preferred test seam is sourcing the canonical helper library and exercising its public API exactly as repository scripts do.

This is the highest practical seam for the shared library and avoids coupling tests to implementation details.

### Secondary integration seam

Representative existing consumer scripts should be executed or statically validated against the canonical helper implementation without modifying their call sites.

This verifies that the compatibility contract holds in real project usage.

### What makes a good test

A good test validates externally observable behavior.

Tests should assert outcomes such as:

- a function exists after sourcing the helper;
- expected variables are initialized or exported;
- commands return the expected status;
- output appears on the correct stream;
- files or logs are created when expected;
- dry-run mode avoids executing side effects;
- non-interactive execution does not hang;
- a failed wrapped command remains a failure;
- a successful retry returns success;
- package and command detection return correct statuses under controlled fixtures;
- counters and summaries reflect recorded operations.

Tests should not assert:

- exact internal helper composition;
- specific private variable names;
- implementation-only branches;
- line ordering unrelated to public behavior;
- whether one public helper delegates to another.

### Modules and domains to test

Tests should cover:

- global variable initialization;
- command detection;
- console output helpers;
- logging;
- package detection;
- package availability;
- AUR availability;
- dynamic list selection;
- GPU detection behavior;
- timed prompt behavior;
- spinner behavior in non-interactive mode;
- status execution;
- retry;
- downloader selection;
- download status integration;
- repository synchronization behavior through controlled repositories or command stubs;
- installation counters;
- item-list rendering;
- final summary rendering.

### Prior art

Existing repository tests, validation scripts, CI commands, shell conventions, and fixtures should be reused where present.

If the repository lacks tests for shell helpers, introduce the smallest possible public-API test harness rather than building multiple low-level seams.

The ideal number of new seams is one.

### Static validation

At minimum, the implementation should pass:

- Bash syntax validation;
- ShellCheck using the repository's accepted configuration;
- sourcing in a controlled shell process;
- checks for duplicate public function definitions;
- checks that required public symbols remain available.

### Compatibility matrix

Before final approval, compare the public surface of the older helper implementation against the canonical integrated implementation.

The matrix should account for:

- functions;
- variables;
- exports;
- accepted options;
- default behavior;
- return statuses;
- expected side effects.

Any intentional difference must be documented and explicitly approved. The default expectation is no intentional difference.

---

## Out of Scope

The following work is outside this specification:

- adding unrelated end-user features;
- redesigning the installer workflow;
- converting the project to another programming language;
- splitting the canonical helper into multiple libraries merely for architectural purity;
- making the helper framework platform-agnostic;
- removing Arch Linux, AUR, pacman, HyDE, or RaVN-specific behavior;
- renaming public functions;
- renaming exported variables;
- requiring consumer scripts to be updated;
- changing package selection policy;
- changing NVIDIA driver policy;
- changing repository branch policy;
- redesigning dry-run semantics;
- replacing Git synchronization with another transport or tool;
- publishing the work to an issue tracker from this document alone;
- broad cleanup of unrelated scripts;
- changing the project's user-facing product vocabulary;
- introducing a new logging backend;
- introducing new runtime dependencies without explicit justification.

---

## Further Notes

This work should be treated as an architectural consolidation, not a feature dump.

The first implementation represents the author's current design language. The second represents valuable functionality accumulated during earlier evolution, experimentation, and improvement.

The goal is not to erase that history mechanically. The goal is to absorb its useful capabilities into a mature canonical framework that reflects the project's present identity.

A successful result should satisfy all of the following:

- Existing scripts continue working.
- Every required helper remains available.
- The final file has a clear internal architecture.
- The file reads as the work of one author.
- Visual output is coherent.
- Error handling is predictable.
- The implementation is easier to maintain than either original.
- The legacy implementation is no longer needed as a competing source of truth.
- A production reviewer can approve the change without requesting structural rework.

The governing review instruction is:

> Review this repository as if you are blocking or approving a production PR.
