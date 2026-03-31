#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  FIXTURE_PATHS=()
}

teardown() {
  local fixture

  for fixture in "${FIXTURE_PATHS[@]}"; do
    rm -f "$fixture"
  done
}

create_project_fixture() {
  local path="$1"
  local function_name="$2"
  local message="$3"

  cat >"$path" <<EOF
${function_name}() { echo "${message}"; }
EOF
  FIXTURE_PATHS+=("$path")
}

@test "custom.aliases loads project alias files" {
  create_project_fixture "$REPO_ROOT/src/aliases/test-custom-aliases.bash" "custom_aliases_test" "custom aliases loaded"

  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$REPO_ROOT"'/src/custom.aliases.bash"
    custom_aliases_test
  '

  [ "$status" -eq 0 ]
  [ "$output" = "custom aliases loaded" ]
}

@test "custom.lib loads project lib files" {
  create_project_fixture "$REPO_ROOT/src/lib/test-custom-lib.bash" "custom_lib_test" "custom lib loaded"

  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$REPO_ROOT"'/src/custom.lib.bash"
    custom_lib_test
  '

  [ "$status" -eq 0 ]
  [ "$output" = "custom lib loaded" ]
}

@test "custom.plugins loads project plugin files" {
  create_project_fixture "$REPO_ROOT/src/plugins/test-custom-plugin.bash" "custom_plugin_test" "custom plugin loaded"

  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$REPO_ROOT"'/src/custom.plugins.bash"
    custom_plugin_test
  '

  [ "$status" -eq 0 ]
  [ "$output" = "custom plugin loaded" ]
}

@test "custom.aliases resolves the project directory when sourced through a symlink" {
  create_project_fixture "$REPO_ROOT/src/aliases/test-custom-aliases-link.bash" "custom_aliases_link_test" "custom aliases symlink loaded"
  mkdir -p "$HOME/.bash_it/aliases"
  ln -s "$REPO_ROOT/src/custom.aliases.bash" "$HOME/.bash_it/aliases/custom.aliases.bash"

  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$HOME"'/.bash_it/aliases/custom.aliases.bash"
    custom_aliases_link_test
  '

  [ "$status" -eq 0 ]
  [ "$output" = "custom aliases symlink loaded" ]
}
