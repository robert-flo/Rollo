# Fail closed for privileged batches

When an administrative batch encounters a privileged failure, dependent tasks will not run and the global result will remain unsuccessful even if other tasks pass. Independent continuation requires explicit authorization and the reconciliation report must list applied, skipped, failed, and pending work. This prevents a partial system mutation from being presented as a complete deployment.
