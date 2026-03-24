#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "bit completion reuses the bash-it completion definition" {
  _bash-it() {
    return 0
  }

  complete -r bash-it bit 2>/dev/null
  complete -o bashdefault -o default -F _bash-it bash-it

  source "$REPO_ROOT/src/completion/bash-it.bash"

  expected="$(complete -p bash-it | sed 's/ bash-it$/ bit/')"

  run complete -p bit

  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "bit completion stays undefined when bash-it completion is missing" {
  complete -r bash-it bit 2>/dev/null

  source "$REPO_ROOT/src/completion/bash-it.bash"

  run complete -p bit

  [ "$status" -ne 0 ]
}
