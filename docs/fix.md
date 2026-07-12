# Fix: npm allow-scripts warning in mise-managed installs

## Problem

npm 11.x emits `npm warn allow-scripts` during `mise install` for npm packages
with lifecycle scripts (e.g. `protobufjs` postinstall in `command-code`).

## Root cause

Two conflicts:

1. `npm_args = "--ignore-scripts=false"` appended after mise's default
   `--ignore-scripts=true`, creating contradictory CLI flags that trigger
   npm11.x's allow-scripts check.
2. `--allow-scripts` as a CLI flag conflicts with `.npmrc` config — npm treats
   them as different mechanisms and warns about uncovered packages.

## What works

In `mise_cli_write_config()` (`framework/mise-cli.sh`):

- **Remove** `npm_args` and `allow_builds` from the mise.toml template
- **Add** `.npmrc` with `allow-scripts=true` to the config directory

```toml
[tools]
node = "${MISE_CLI_NODE_VERSION}"
"npm:${MISE_CLI_PACKAGE}" = "${MISE_CLI_VERSION}"
```

```ini
# .npmrc in config dir
allow-scripts=true
```

## Why it works

- mise's default `--ignore-scripts=true` is sufficient — `mise_cli_install_config`
  runs postinstall scripts separately after `mise install`.
- `.npmrc` with `allow-scripts=true` tells npm to allow all lifecycle scripts
  without needing a CLI flag.
- No contradictory flags → no warning.

## Verification

```bash
bash Scripts/ravn/test-task.sh command-code  # Docker: no npm warn lines
bash Scripts/ravn/tests/22-command-code-lifecycle.sh  # Full lifecycle
```
