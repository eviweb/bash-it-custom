
#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

new_fixture() {
  local file="${1:-dummy}"

  cat >"$HOME/${file}.bash" <<EOF
${file}_test() { echo "${file} is loaded."; }
EOF
}

run_loader() {
  local dir="$1"

  run bash -lc '
    source "'"$REPO_ROOT"'/src/loader.sh"
    loadCustomFrom "'"$dir"'"
  '
}

@test "loadCustomFrom loads bash files from a directory" {
  new_fixture "dummy1"
  new_fixture "dummy2"

  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$REPO_ROOT"'/src/loader.sh"
    loadCustomFrom "$HOME"
    dummy1_test
    dummy2_test
  '

  [ "$status" -eq 0 ]
  [[ "$output" == *"dummy1 is loaded."* ]]
  [[ "$output" == *"dummy2 is loaded."* ]]
}

@test "loadCustomFrom fails when the directory does not exist" {
  run_loader "/non/existing/path"

  [ "$status" -eq 1 ]
  [ "$output" = "The given location '/non/existing/path' does not exist, abort;" ]
}

@test "loadCustomFrom stays silent when the directory is empty" {
  run bash -lc '
    export HOME="'"$HOME"'"
    source "'"$REPO_ROOT"'/src/loader.sh"
    loadCustomFrom "$HOME"
  '

  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
