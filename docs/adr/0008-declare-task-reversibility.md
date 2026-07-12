# Declare administrative reversibility

Administrative tasks will declare whether their changes are reversible, compensatable, irreversible, or not safe to automate. The runner will not promise universal rollback: it will perform preflight and backups where appropriate, use automatic recovery only for declared reversible changes, and report partial or manual recovery requirements for the rest. This avoids destructive “undo” logic that can make system failures worse.
