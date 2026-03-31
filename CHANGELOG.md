# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

### [Unreleased][unreleased]

#### Removed
- remove alias_completion script
- remove alias_completion reference from README
- remove `shunit2` and `shell-testlib` from the project test workflow

#### Fixed
- make `loadCustomFrom` succeed on empty directories and return instead of exiting on missing paths
- make `install.sh uninstall` succeed when external links are intentionally preserved
- make `install.sh` fail fast when required `BASH_IT` component directories are missing
- make `install.sh` return a failure status when install or uninstall actions hit permission errors
- make `install.sh` fail fast when a managed target path already exists as a directory
- make `install.sh -U` propagate install failures on invalid target structures
- make installer and custom entry points resolve symlinks without relying on GNU `readlink -f`
- reuse the `bash-it` completion definition for the `bit` alias
- replace `which "${cmd}"` by `command -v "${cmd}"` in waf command to look for an existing command
- fix legacy `which-alias` test behavior and migrate coverage to `bats`

#### Added
- `check.sh` to run the local verification workflow
- optional `shellcheck` support in `check.sh`
- exclude generated `rustup` completion code from `shellcheck`
- `install.sh --check` (`-c`) to validate the current `BASH_IT` setup without changing it
- `install.sh -n` dry-run mode for install and uninstall actions
- clearer `install.sh` action messages for install, update, uninstall, and skipped unmanaged links
- `bats` proof of concept for `which-alias`
- `bats` proof of concept for `bash-it` completion
- `bats` proof of concept for the custom loader
- `bats` proof of concept for the installer
- `bats` proof of concept for the updater
- `bats` coverage for `custom.completion`
- `bats` coverage for `custom.aliases`, `custom.lib`, and `custom.plugins`
- `bats` coverage for sourcing `custom.aliases` through a symlink
- `bats` coverage for missing local bashrc directories
- `bats` coverage for `install.sh --check`
- `bats` coverage for installer symlink replacement and broken-link edge cases
- `bats` coverage for update on invalid `BASH_IT` structures
- full `bats` coverage for the project test suite
- test coverage for `bit` completion
- new aliases:
    + test kitchen
    + new environment related aliases
    + more git aliases
    + some python aliases
- new plugins:
    + which_alias_for (alias waf)
    + which_alias_is (alias wai)
- new lib:
    + init: to initialize the shell environment before all

### 0.1.1 - 2016-04-05
#### Changed
- lib/custom.bash link updated and renamed to lib/custom.lib.bash
- refactor tests -> extract common functions in support libraries

#### Fixed
- bash-it aliases plural issue in component types
- installer can be run twice

#### Added
- local-completion plugin
- local-bashrc plugin
- more git aliases
- environment related aliases
- projects plugin additional aliases
- custom loader:
    * custom
- updater
- automatic alias completion

### 0.1.0 - 2015-10-01
#### Added
- package files
- installer
- internal loader
- custom loaders:
    * aliases
    * completion
    * lib
    * plugins
- bash-it completion for the 'bit' shortcut
- bash-it aliases
- git aliases
