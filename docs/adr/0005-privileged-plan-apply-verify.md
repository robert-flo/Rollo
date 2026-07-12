# Privileged tasks use plan, approval, apply, and verify

The RaVN suite will remain the single execution surface for user tools, system packages, and host configuration, including privileged operations. Privileged work must use a two-phase `plan → approval → apply → verify` contract: planning is read-only, approval is explicit for the privileged batch, apply performs only declared operations, and verification evaluates observable postconditions rather than trusting command exit status. This keeps the suite comprehensive without allowing hidden or unaudited elevation.

## Considered options

- Prompt independently inside each task: rejected because large installations become repetitive and task code can hide the true permission boundary.
- Allow tasks to invoke `sudo` silently: rejected because it makes authorization and auditability implicit.

## Consequences

Tasks must declare permissions, ownership boundaries, and postconditions. The runner will need a privileged execution profile and a plan representation before administrative tasks can be migrated safely.
