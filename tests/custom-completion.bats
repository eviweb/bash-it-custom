
#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.bash_completion.d"
  export TEST_SYSROOT="$BATS_TEST_TMPDIR/sysroot"
  mkdir -p "$TEST_SYSROOT/etc/bash_completion.d" "$BATS_TEST_TMPDIR/bin"
  : >"$TEST_SYSROOT/etc/bash_completion.d/cargo"
  cat >"$BATS_TEST_TMPDIR/bin/rustc" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "--print" ] && [ "\$2" = "sysroot" ]; then
  printf '%s\n' "$TEST_SYSROOT"
fi
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/rustc"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

create_completion_fixture() {
  local path="$1"
  local function_name="$2"
  local message="$3"

  cat >"$path" <<EOF
${function_name}() { echo "${message}"; }
EOF
}

@test "custom.completion loads project and local completion files" {
  create_completion_fixture "$REPO_ROOT/src/completion/test-project.bash" "project_completion_test" "project completion loaded"
  create_completion_fixture "$HOME/.bash_completion.d/test-local.bash" "local_completion_test" "local completion loaded"

  run bash -lc '
    export HOME="'"$HOME"'"
    export PATH="'"$PATH"'"
    source "'"$REPO_ROOT"'/src/custom.completion.bash"
    project_completion_test
    local_completion_test
  '

  rm -f "$REPO_ROOT/src/completion/test-project.bash"

  [ "$status" -eq 0 ]
  [[ "$output" == *"project completion loaded"* ]]
  [[ "$output" == *"local completion loaded"* ]]
}

@test "custom.completion ignores missing local completion directory" {
  rmdir "$HOME/.bash_completion.d"

  run bash -lc '
    export HOME="'"$HOME"'"
    export PATH="'"$PATH"'"
    source "'"$REPO_ROOT"'/src/custom.completion.bash"
  '

  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
