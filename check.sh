#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v bats >/dev/null 2>&1; then
  echo "==> bats is required to run the test suite" >&2
  exit 1
fi

if command -v shellcheck >/dev/null 2>&1; then
  mapfile -t shell_files < <(find "$ROOT_DIR" -path "$ROOT_DIR/lib" -prune -o -type f \( -name '*.bash' -o -name '*.sh' \) -print)
  echo "==> Running shellcheck"
  shellcheck "${shell_files[@]}"
else
  echo "==> Skipping shellcheck: shellcheck not found"
fi

echo "==> Running bats suite"
bats "$ROOT_DIR/tests"/*.bats
