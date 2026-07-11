# ADR 0003: Standardize mise for versioned npm CLIs

- Status: Accepted
- Date: 2026-07-10
- Related: GitHub issue #27

## Context

RaVN needs to install CLI tools reliably while keeping installation, verification and reset explicit. The OpenCode pilot compared an isolated mise task with a hardened npx wrapper.

## Decision

Use mise as the default backend for versioned npm CLIs. Keep `omarchy-npx-install` as an explicit fallback for packages that need it. Do not add Nix as a mandatory dependency; evaluate it only through a separate pilot.

## Rationale

mise gives the task ownership of the Node runtime, npm package version, configuration and wrapper. That state can be inspected and reset. It also allows execution without shell initialization when the task wrapper uses `mise exec` explicitly. npx remains useful, but its runtime resolution and network behavior are more implicit and less transparent.

## Consequences

- New npm CLI tasks should prefer `mise` and implement a real `verify()`.
- Required npm lifecycle scripts must be handled explicitly and verified.
- OpenCode enables `allow_builds = true` for its npm tool entry and retains explicit postinstall verification for older mise/npm combinations.
- `latest` must be an intentional policy, not an accidental default.
- Nix may be added later as an optional backend for tasks where its reproducibility justifies its operational cost.
