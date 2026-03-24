# TODO

## Test Strategy

- [x] Decide to migrate the test suite from `shunit2` to `bats`
- [ ] Document the decision criteria for test tooling:
  - maintenance cost
  - readability
  - portability on Ubuntu
  - dependency footprint
  - compatibility with current CI and local workflows
- [x] Run a small proof of concept by migrating one existing test file to `bats`
- [x] Migrate a second small test file to `bats` to validate the incremental approach
- [x] Migrate `loader_test.sh` to `bats` in parallel to validate environment setup patterns
- [x] Migrate `installer_test.sh` to `bats` in parallel before removing `shunit2`
- [x] Migrate `updater_test.sh` to `bats` in parallel
- [ ] Compare `shunit2` vs `bats` on this repository with concrete findings
- [x] Define a progressive migration plan instead of a big-bang rewrite
- [x] Keep the existing `shunit2` suite running until feature parity is reached
- [x] Remove the `shunit2` git submodule after the migration is complete and validated
- [x] Remove the `shell-testlib` git submodule from the project test workflow after migration
- [x] Remove the legacy `shunit2` test files once `bats` coverage is complete
- [x] Run the project test workflow exclusively with `bats`

## Test Coverage

- [x] Add tests for the `src/custom.*.bash` entry points
- [ ] Add tests for `install.sh` update mode
- [ ] Add tests covering symlink creation and replacement edge cases
- [ ] Add tests for local loaders when `${HOME}/.bashrc.d` or `${HOME}/.bash_completion.d` are absent
- [ ] Add tests for `bit` completion behavior when `bash-it` completion is unavailable or changes shape
- [ ] Add regression tests for shell helpers that depend on external tools behavior

## Tooling

- [x] Add a `check.sh` script to run the project verification workflow from one command
- [x] Run the full test suite from `check.sh`
- [x] Add optional `shellcheck` support when available locally
- [x] Document the local verification workflow in `README.md`

## Compatibility

- [ ] Document the supported or tested versions of Bash, Ubuntu, and `bash-it`
- [ ] Review scripts for dependencies on GNU-specific behaviors such as `grep -P` and `sed -r`
- [ ] Replace fragile shell pipelines with simpler shell-native logic where practical
- [ ] Verify the `bit` alias completion behavior against current `bash-it` releases before the next tag

## Documentation

- [x] Keep `README.md`, `CHANGELOG.md`, and `VERSION` aligned for the current development state
- [ ] Add a short project scope section to clarify what belongs in this repository
- [ ] Document the installation, update, and uninstall expectations more explicitly

## Installation UX

- [x] Add a dry-run mode to `install.sh`
- [x] Print clearer messages for install, update, and uninstall operations
- [ ] Validate edge cases around invalid or partial `BASH_IT` installations
