# TODO

## Test Strategy

- [ ] Decide whether to migrate the test suite from `shunit2` to `bats`
- [ ] Document the decision criteria for test tooling:
  - maintenance cost
  - readability
  - portability on Ubuntu
  - dependency footprint
  - compatibility with current CI and local workflows
- [x] Run a small proof of concept by migrating one existing test file to `bats`
- [x] Migrate a second small test file to `bats` to validate the incremental approach
- [ ] Compare `shunit2` vs `bats` on this repository with concrete findings
- [ ] If `bats` is adopted, define a progressive migration plan instead of a big-bang rewrite
- [ ] Keep the existing `shunit2` suite running until feature parity is reached
- [ ] Remove the `shunit2` git submodule only after the migration is complete and validated

## Test Coverage

- [ ] Add tests for the `src/custom.*.bash` entry points
- [ ] Add tests for `install.sh` update mode
- [ ] Add tests covering symlink creation and replacement edge cases
- [ ] Add tests for local loaders when `${HOME}/.bashrc.d` or `${HOME}/.bash_completion.d` are absent
- [ ] Add tests for `bit` completion behavior when `bash-it` completion is unavailable or changes shape
- [ ] Add regression tests for shell helpers that depend on external tools behavior

## Tooling

- [x] Add a `check.sh` script to run the project verification workflow from one command
- [ ] Run the full test suite from `check.sh`
- [ ] Add optional `shellcheck` support when available locally
- [ ] Document the local verification workflow in `README.md`

## Compatibility

- [ ] Document the supported or tested versions of Bash, Ubuntu, and `bash-it`
- [ ] Review scripts for dependencies on GNU-specific behaviors such as `grep -P` and `sed -r`
- [ ] Replace fragile shell pipelines with simpler shell-native logic where practical
- [ ] Verify the `bit` alias completion behavior against current `bash-it` releases before the next tag

## Documentation

- [ ] Keep `README.md`, `CHANGELOG.md`, and `VERSION` aligned for each release
- [ ] Add a short project scope section to clarify what belongs in this repository
- [ ] Document the installation, update, and uninstall expectations more explicitly

## Installation UX

- [ ] Add a dry-run mode to `install.sh`
- [ ] Print clearer messages for install, update, and uninstall operations
- [ ] Validate edge cases around invalid or partial `BASH_IT` installations
