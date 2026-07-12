#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ravn-admin-docker-reports.XXXXXX")
trap 'rm -rf "$REPORT_DIR"' EXIT

if ! command -v docker > /dev/null 2>&1 || ! docker info > /dev/null 2>&1; then
  printf 'SKIP: administrative Docker harness — Docker unavailable\n'
  exit 0
fi

if bash "$RAVN_DIR/test-task-admin-docker.sh" admin-lifecycle \
  --report-dir "$REPORT_DIR"; then
  printf 'FAIL: Docker approval was not required\n' >&2
  exit 1
fi

bash "$RAVN_DIR/test-task-admin-docker.sh" admin-lifecycle --approve \
  --report-dir "$REPORT_DIR"
grep -q '"mode": "docker"' "$REPORT_DIR/admin-fixture-success.json"
grep -q '"task": "admin-fixture"' "$REPORT_DIR/admin-fixture-success.json"
grep -q '"scenario": "success"' "$REPORT_DIR/admin-fixture-success.json"
grep -q '"result": "verified"' "$REPORT_DIR/admin-fixture-success.json"

if bash "$RAVN_DIR/test-task-admin-docker.sh" admin-lifecycle --approve \
  --scenario verify-failure --report-dir "$REPORT_DIR"; then
  printf 'FAIL: Docker verification failure unexpectedly passed\n' >&2
  exit 1
fi
grep -q '"result": "failed"' "$REPORT_DIR/admin-fixture-verify-failure.json"

printf 'PASS: administrative Docker harness contract\n'
