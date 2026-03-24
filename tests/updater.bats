#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export HOME="$BATS_TEST_TMPDIR/home"
  export BASH_IT="$HOME/.bash_it"
  mkdir -p "$BASH_IT"/{lib,custom,aliases,plugins,completion}
}

linked_files() {
  printf '%s\n' \
    "$BASH_IT/aliases/custom.aliases.bash" \
    "$BASH_IT/completion/custom.completion.bash" \
    "$BASH_IT/custom/custom.bash" \
    "$BASH_IT/lib/custom.lib.bash" \
    "$BASH_IT/plugins/custom.plugins.bash"
}

run_installer() {
  run bash "$REPO_ROOT/install.sh" "$@"
}

@test "install.sh -U applies update v0.1.1 and installs current links" {
  ln -s "$REPO_ROOT/src/custom.bash" "$BASH_IT/lib/custom.bash"

  run_installer -U

  [ "$status" -eq 0 ]
  [ ! -L "$BASH_IT/lib/custom.bash" ]

  while IFS= read -r file; do
    [ -L "$file" ]
    [ -e "$(readlink -f "$file")" ]
  done < <(linked_files)
}
