# Use a global visual language with a gum selector and Bash fallback

## Status

Accepted during the Ravn task runner visual integration design session.

## Decision

The task runner will use `global_fn.sh` as its sole source of colors, Nerd Font
icons, status helpers, and presentation vocabulary. Its interactive menu and
task selector will use `gum` with task items that include a semantic icon, task
name, and category. The UI mode is controlled by `RAVN_UI=auto|gum|bash`.

The interface uses the shared RavnVM banner composition on every screen, with
the task-runner subtitle `RaVN Task Runner` and the shared author byline. All
user-facing copy is English. Shared section titles are `Choose an action`,
`Task inventory`, `Choose tasks`, `Confirm selection`, and `Task results`.

`gum` is an interactive dependency validated before any menu is shown. On Arch,
missing `git`, `curl`, or `gum` may be installed conditionally with the existing
preflight strategy. Non-Arch systems are unsupported and exit before the menu.
If installation fails, the runner stops rather than presenting a partial UI.

`RAVN_UI=bash` provides a numbered selector for limited terminals. We do not
attempt fragile automatic Nerd Font detection; the explicit override is the
reliable escape hatch. Non-interactive, dry-run, CI, and no-TTY flows remain
Bash-compatible and never invoke `gum`.

The interactive menu uses `gum` for the main actions and task selection. The
universal row format is one-based `number → icon → task → category`; the same
format is used by the Bash fallback and by `gum`. Task selection is two-level:
the user selects a task family with counts first, then selects one or more
tasks. `All categories` opens one global list with category labels preserved.
`Run full setup` bypasses task selection and confirms before running all tasks;
verification, integration tests, and resets use the category/task selectors.

The task inventory is summarized by category before selection. Categories and
tasks are sorted deterministically, with unknown categories last. Task families
and task rows both start at `1`; `q` means back or exit. `Esc` is treated as
back, never as an error, and cancelled selections never execute partially.

Operations with effects use a confirmation screen through `gum confirm` or the
Bash equivalent. Verification may run directly. Every action returns to the
main menu. The existing `global_fn.sh` summary remains the canonical final
report; task execution may show brief statuses but must not duplicate or
reinterpret the summary.

## Consequences

- The menu and task output share one author identity and one visual vocabulary.
- Task selection can be multi-select for verification, integration tests, and
  reset operations. Categories and tasks use one-based numbering consistently;
  `q` is reserved for back or exit.
- Direct subcommands and task execution contracts remain unchanged.
- Interactive startup may install missing UI dependencies on supported Arch
  hosts before any task-runner output is displayed.
- A limited terminal can still use the explicit Bash interface.
