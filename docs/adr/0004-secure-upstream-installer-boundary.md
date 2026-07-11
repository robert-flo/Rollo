# Secure upstream installer boundary

Status: accepted

Upstream installer tasks must download vendor scripts over HTTPS before
execution; they must not use direct `curl | bash`. The backend records the URL,
download hash, and execution result, supports an expected SHA-256 when the
vendor publishes one, and does not escalate to root unless the task explicitly
requires it. The backend always computes and records the downloaded script's
SHA-256 automatically; an expected checksum is optional, but when supplied it
must match or installation fails closed. This gives future curl-installed tools
a shared trust boundary without forcing agents to calculate checksums manually
or pretending that an unsigned vendor script is cryptographically verified.

Upstream tasks follow the same lifecycle semantics as mise-managed CLI tasks:
`run` does not update a verified installation, `check-updates` is read-only, and
`update` is explicit. When the vendor installer cannot support a lifecycle
operation, the backend reports it as unsupported rather than inventing a
different success state.

The backend owns a user-level installation boundary. A vendor script that
ignores the declared task-owned directory must use an explicit adapter; it is
not accepted as a silent exception because reset and rollback would otherwise
be unable to account for the files it changed.

When a vendor provides a native update and update-check command, the upstream
backend uses those commands for lifecycle operations instead of rerunning the
remote bootstrap script. The bootstrap script remains the install and recovery
path; the task declares the provider-native version, update-check, and update
commands when available.

Authentication is outside the installer lifecycle. Tasks must not open a
browser, request interactive credentials, or persist API keys and tokens.
Version verification must work without authentication; authenticated first use
is a separate manual validation concern.

Every upstream task requires both deterministic contract coverage with a
controlled installer double and an isolated integration check against the real
vendor path. The first proves lifecycle behavior without network dependence;
the second proves that the current vendor installer and executable still work.

Downloaded installers run through an explicitly configured shell and argument
array in a controlled user-level environment. The backend never uses `eval`,
never infers execution from a downloaded file's shebang, and records redacted
output and exit status.

The first upstream backend scope is limited to vendor-provided shell
installers fetched over HTTPS, equivalent to a `curl -fsSL URL | bash` flow but
downloaded and verified before execution. It does not become a general archive
or binary-distribution backend; those mechanisms require a separate contract
when a real task needs them.

The remote bootstrap script and the installed tool have separate lifecycles.
The bootstrap is not rerun to detect updates; `run` only repairs absent or
broken state, while `check-updates` and `update` use provider-native commands
when available. Re-running the bootstrap is a recovery path, not the normal
update path.

Reliability is a precondition for supporting upstream updates. The backend must
refuse an update before mutation when it cannot establish a verified recovery
path. An update that leaves the installation unrecoverable is reported as
`rollback-failed`; an irreversible in-place update is not a supported
operation.

Before any supported upstream update, a preflight must create and verify a
recoverable snapshot of the current task-owned installation. The update may
proceed only after the snapshot's executable and version are verified; failed
promotion must restore and re-verify that snapshot.

Installation resources and user data are separate ownership domains. Reset and
rollback may manage only the task-owned executable, wrapper, snapshots, and
evidence; they must not remove provider configuration, sessions, memory,
plugins, or credentials. A vendor layout that mixes these domains requires an
adapter before reset or update is supported.

The public command surface is a single RaVN-managed wrapper at
`$HOME/.local/bin/<command>`. Verification executes that wrapper, while the
vendor executable remains inside the task-owned installation directory and is
not exposed through additional global links.
