# Use declarative metadata with executable administrative hooks

Administrative tasks will combine declarative metadata with executable lifecycle hooks. The metadata lets the runner plan permissions, ownership, conflicts, reversibility, activation, and testing before execution; hooks provide task-specific plan, apply, verify, evidence, and recovery behavior. This keeps the common safety boundary inspectable without forcing every system configuration into an artificial generic implementation.
