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

remove_bash_it_component_dir() {
  rm -rf "$BASH_IT/$1"
}

@test "install.sh dry-run reports install actions without creating links" {
  run_installer -n

  [ "$status" -eq 0 ]
  [[ "$output" == *"Dry run: install"* ]]
  [[ "$output" == *"Would link"* ]]

  while IFS= read -r file; do
    [ ! -e "$file" ]
  done < <(linked_files)
}

@test "install.sh installs the custom entry points" {
  run_installer

  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing bash-it-custom into"* ]]

  while IFS= read -r file; do
    [ -L "$file" ]
    [ -e "$(readlink -f "$file")" ]
  done < <(linked_files)
}

@test "install.sh uninstall removes links managed by this repository" {
  run_installer
  [ "$status" -eq 0 ]

  run_installer -u

  [ "$status" -eq 0 ]
  [[ "$output" == *"Uninstalling bash-it-custom from"* ]]

  while IFS= read -r file; do
    [ ! -L "$file" ]
  done < <(linked_files)
}

@test "install.sh uninstall keeps links that do not point to this repository" {
  external_file="$HOME/custom.aliases.bash"
  touch "$external_file"
  ln -s "$external_file" "$BASH_IT/aliases/custom.aliases.bash"

  run_installer -u

  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping unmanaged link"* ]]
  [ -L "$BASH_IT/aliases/custom.aliases.bash" ]
}

@test "install.sh dry-run reports uninstall actions without removing managed links" {
  run_installer
  [ "$status" -eq 0 ]

  run_installer -n -u

  [ "$status" -eq 0 ]
  [[ "$output" == *"Dry run: uninstall"* ]]
  [[ "$output" == *"Would unlink"* ]]

  while IFS= read -r file; do
    [ -L "$file" ]
  done < <(linked_files)
}

@test "install.sh fails when BASH_IT is unset" {
  run env -u BASH_IT HOME="$HOME" bash "$REPO_ROOT/install.sh"

  [ "$status" -eq 1 ]
  [ "$output" = "No bash-it installation found, abort." ]

  run env -u BASH_IT HOME="$HOME" bash "$REPO_ROOT/install.sh" -u

  [ "$status" -eq 1 ]
  [ "$output" = "No bash-it installation found, abort." ]
}

@test "install.sh fails when BASH_IT points to an invalid path" {
  run env BASH_IT="/wrong/path" HOME="$HOME" bash "$REPO_ROOT/install.sh"

  [ "$status" -eq 1 ]
  [ "$output" = "Invalid path for bash-it: /wrong/path, abort." ]

  run env BASH_IT="/wrong/path" HOME="$HOME" bash "$REPO_ROOT/install.sh" -u

  [ "$status" -eq 1 ]
  [ "$output" = "Invalid path for bash-it: /wrong/path, abort." ]
}

@test "install.sh fails when a required BASH_IT component directory is missing" {
  remove_bash_it_component_dir "plugins"

  run_installer

  [ "$status" -eq 1 ]
  [ "$output" = "Missing bash-it component directory: $BASH_IT/plugins, abort." ]
}

@test "install.sh dry-run also fails when a required BASH_IT component directory is missing" {
  remove_bash_it_component_dir "plugins"

  run_installer -n

  [ "$status" -eq 1 ]
  [ "$output" = "Missing bash-it component directory: $BASH_IT/plugins, abort." ]
}

@test "install.sh can run twice" {
  run_installer
  [ "$status" -eq 0 ]

  run_installer

  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing bash-it-custom into"* ]]

  while IFS= read -r file; do
    [ -L "$file" ]
    [ -e "$(readlink -f "$file")" ]
  done < <(linked_files)
}

@test "install.sh update reports update actions" {
  ln -s "$REPO_ROOT/src/custom.bash" "$BASH_IT/lib/custom.bash"

  run_installer -U

  [ "$status" -eq 0 ]
  [[ "$output" == *"Updating bash-it-custom in"* ]]
}

@test "install.sh displays usage" {
  run_installer -h

  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}
