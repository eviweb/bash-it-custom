#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  source "$REPO_ROOT/src/plugins/which-alias.bash"

  command() {
    printf '%s\n' "$1"
    return 0
  }

  alias() {
    printf '%b' "${STUB_ALIAS_OUTPUT:-}"
  }
}

strip_ansi() {
  printf '%b' "$1" | sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mK]//g'
}

trim_trailing_eof() {
  printf '%s' "$1" | sed -e '${s/[[:space:]]*$//}'
}

normalize_output() {
  trim_trailing_eof "$(strip_ansi "$1")"
}

collapse_whitespace() {
  printf '%s' "$1" | tr -d '[:space:]'
}

@test "which_alias_for lists aliases for a command" {
  STUB_ALIAS_OUTPUT="alias a='cmd'\nalias b='cmd'\nalias c='fake'\nalias d='cmd'\nalias e='fake'"

  run which_alias_for cmd

  [ "$status" -eq 0 ]
  [ "$(normalize_output "$output")" = "$(printf '%b' "alias a='cmd'\nalias b='cmd'\nalias d='cmd'")" ]
}

@test "which_alias_for -s returns compact alias names" {
  STUB_ALIAS_OUTPUT="alias a='cmd'\nalias b='cmd'\nalias c='fake'\nalias d='cmd'\nalias e='fake'"

  run which_alias_for -s cmd

  [ "$status" -eq 0 ]
  [ "$(collapse_whitespace "$output")" = "abd" ]
}

@test "which_alias_is -s returns the alias command body" {
  STUB_ALIAS_OUTPUT="alias a='cmd --flag'\nalias aa='fake'\nalias aaba='fake'"

  run which_alias_is -s a

  [ "$status" -eq 0 ]
  [ "$(normalize_output "$output")" = "cmd --flag" ]
}
