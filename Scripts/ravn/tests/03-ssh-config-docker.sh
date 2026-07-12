#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${RAVN_ADMIN_DOCKER_IMAGE:-archlinux:latest}"

command -v docker > /dev/null || {
  printf 'SKIP: docker is not available\n'
  exit 0
}

docker run --rm \
  -e RAVN_TASK=/repo/tasks/90-system/03-ssh-config.sh \
  -v "${RAVN_DIR}:/repo:ro" \
  "$IMAGE" bash /repo/tests/fixtures/ssh-config-docker-inner.sh
