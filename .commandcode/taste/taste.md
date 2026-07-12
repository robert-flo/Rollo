# mise
- Use mise for managing CLI tools and npm packages instead of homebrew or global npm installs. Confidence: 0.80

# git-workflow
- Create worktrees from the dev branch for changes, then sync back to dev as the single source of truth. Confidence: 0.75
- After merging branches to dev, clean up stale worktrees and remote branches to keep the repository tidy. Confidence: 0.65

# testing
- When refactoring shell scripts, test old vs new side-by-side to verify functional parity before replacing. Confidence: 0.75
- Include visual section separators (e.g., `# ─── Happy path ───`) in lifecycle test files for readability and consistency. Confidence: 0.70

# shell
- When refactoring shared shell libraries (global_fn.sh), maintain backward compatibility so consuming scripts don't need code changes. Confidence: 0.70

# workflow
- Prefer latest versions over pinned versions when installing packages. Confidence: 0.65
- Document agreed-upon decisions and plans in docs/ for session continuity and agent guidance. Confidence: 0.70
- Keep work tickets and PRs atomic for maintainable and testable results. Confidence: 0.70
- For migrating legacy tasks to canonical admin tasks, use the 4-ticket pattern: (1) create canonical task, (2) add lifecycle test, (3) add Docker regression test, (4) retire legacy task. Tickets 2 and 4 block on 1; ticket 4 blocks on 2 and 3. Confidence: 0.70

# testing
- When completing a migration/refactoring ticket, run the full relevant test suite (not just discovery) to verify functionality before declaring done. Confidence: 0.70
