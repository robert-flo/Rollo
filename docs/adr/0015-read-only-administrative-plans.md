# Keep administrative plans read-only

The administrative `plan()` hook may inspect the system, dependencies, permissions, ownership, conflicts, and effective configuration, but it may not mutate anything. All mutations, including package installation, file writes, service changes, and permission changes, belong exclusively to the approved `apply()` phase. This makes the approval boundary meaningful and prevents “dry-run” code from changing the host.
