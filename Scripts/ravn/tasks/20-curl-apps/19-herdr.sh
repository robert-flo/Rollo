#!/usr/bin/env bash
# ─── RaVN Task: Herdr CLI ───────────────────────────────────────────────────

# shellcheck disable=SC2034
CLI_COMMAND="herdr"
# shellcheck disable=SC2034
CLI_INSTALLER="upstream"
# shellcheck disable=SC2034
CLI_INSTALL_URL="https://herdr.dev/install.sh"
# Herdr reports its installed version through --version and updates through
# its native update command. It has no non-mutating update-check command.
# shellcheck disable=SC2034
CLI_VERSION_ARGS=(--version)
# shellcheck disable=SC2034
CLI_UPDATE_ARGS=(update)
# The vendor installer writes to HERDR_INSTALL_DIR.
# shellcheck disable=SC2034
CLI_INSTALL_DIR_ENV="HERDR_INSTALL_DIR"

ravn_cli_task
