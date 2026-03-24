#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Running shunit2 suite"
bash "$ROOT_DIR/tests/testsuite.sh"

if command -v bats >/dev/null 2>&1; then
  echo "==> Running bats suite"
  bats "$ROOT_DIR/tests"/*.bats
else
  echo "==> Skipping bats suite: bats not found"
fi
