# Issue #225 acceptance audit

Audit date: 2026-07-13

## Result

The task runner visual interface is implemented and covered by the relevant
unit, interaction, preflight, and non-Docker regression tests. The following
criteria remain partial or deferred and prevent closing #225 as fully complete:

- Task descriptions are not shown in a preview or confirmation screen.
- Discovery failure and an empty inventory are not reported as distinct states
  before the interactive selector opens.
- The real entrypoint does not yet have a dedicated end-to-end assertion for
  `RAVN_UI=auto` or for proving that no-TTY execution never invokes `gum`.

## Criterion mapping

| # | Status | Evidence |
|---:|:---:|---|
| 1 | PASS | Shared RaVN banner in the interactive runner |
| 2 | PASS | `RaVN Task Runner` banner subtitle |
| 3 | PASS | Shared Roberto Flores byline |
| 4 | PASS | Runner-facing copy is English |
| 5 | PASS | Shared section vocabulary |
| 6 | PASS | Colors and presentation helpers come from `global_fn.sh` |
| 7 | PASS | Shared Nerd Font icon catalog is used in rows and actions |
| 8 | PASS | Interactive dependency preflight before the menu |
| 9 | PASS | Conditional Arch dependency installation |
| 10 | PASS | Preflight installation failure stops before the menu |
| 11 | PASS | Unsupported-system message and early exit |
| 12 | PASS | Numbered Bash fallback via `RAVN_UI=bash` |
| 13 | PASS | Gum selectors in interactive mode |
| 14 | PARTIAL | Code avoids gum without a TTY; dedicated entrypoint assertion remains |
| 15 | PARTIAL | `auto` resolves to gum; dedicated entrypoint assertion remains |
| 16 | PASS | Explicit `RAVN_UI=gum` path |
| 17 | PASS | Explicit `RAVN_UI=bash` path |
| 18 | PASS | Task inventory before selection |
| 19 | PASS | Category counts |
| 20 | PASS | Deterministic category ordering |
| 21 | PASS | Deterministic task ordering |
| 22 | PASS | Unknown category fallback ordering in the selector implementation |
| 23 | PASS | Two-level task-family selection |
| 24 | PASS | `All categories` selection |
| 25 | PASS | One-based category and task numbering |
| 26 | PASS | Number, icon, task, and category row format |
| 27 | PASS | Multi-selection for task operations |
| 28 | PASS | Full setup bypasses task selection |
| 29 | PASS | Effectful actions require confirmation |
| 30 | PASS | Verification path runs without confirmation |
| 31 | PASS | Gum and Bash confirmation paths |
| 32 | PASS | Escape returns from nested selectors |
| 33 | PASS | Cancelled selections do not execute work |
| 34 | PASS | Actions return to the main menu |
| 35 | PASS | Banner is rendered on interactive screens |
| 36 | PASS | Screens are cleared between views and results remain readable |
| 37 | PASS | Runner emits task status updates |
| 38 | PASS | Canonical global task summary is retained |
| 39 | DEFERRED | Task descriptions are not currently previewed |
| 40 | DEFERRED | Discovery failure is not distinguished from empty inventory |
| 41 | DEFERRED | Empty or failed discovery can still reach selector handling |
| 42 | PASS | Existing lifecycle functions remain the execution seam |
| 43 | PASS | Direct subcommands remain available |
| 44 | PASS | Dry-run remains non-interactive |
| 45 | PASS | Internal task names and categories remain stable |
| 46 | PASS | Bash and gum share row ordering and icons |
| 47 | PASS | Executable menu and entrypoint tests exist |
| 48 | PASS | UI decisions are recorded in ADR 0018 |

## Proposed final status comment for #225

> The visual task-runner interface is implemented through PRs #236, #237,
> #242, #243, and #244. The main menu, shared visual language, Bash/gum
> selectors, preflight, confirmations, cancellation behavior, and workflow
> regression coverage are complete. Three criteria remain intentionally open:
> task-description previews, distinct discovery-failure versus empty-inventory
> reporting, and dedicated end-to-end assertions for `RAVN_UI=auto` and no-TTY
> gum avoidance. Issue #225 should remain open until those exceptions are
> either implemented or explicitly accepted as out of scope.
