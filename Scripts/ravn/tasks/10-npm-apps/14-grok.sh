#!/usr/bin/env bash
# ─── RaVN Task: Grok CLI ────────────────────────────────────────────────────

# shellcheck disable=SC2034
UPSTREAM_COMMAND="grok"
# shellcheck disable=SC2034
UPSTREAM_INSTALL_URL="https://x.ai/cli/install.sh"
# shellcheck disable=SC2034
UPSTREAM_VERSION_ARGS=(version)
# The vendor installer writes ~/.grok; isolate that home and direct its binary
# output into the task-owned installation directory.
# shellcheck disable=SC2034
UPSTREAM_INSTALL_DIR_ENV="GROK_BIN_DIR"

ravn_upstream_task
