#!/usr/bin/env bash
# ─── RaVN Task: OpenCode CLI ────────────────────────────────────────────────

# shellcheck disable=SC2034
CLI_PACKAGE="opencode-ai"
# shellcheck disable=SC2034
CLI_COMMAND="opencode"

if [[ -f ${RAVN_DIR}/framework/mise-cli.sh ]]; then
  # shellcheck disable=SC1091
  source "${RAVN_DIR}/framework/mise-cli.sh"
else
  # shellcheck disable=SC1091
  source /mise-cli.sh
fi
mise_cli_task
