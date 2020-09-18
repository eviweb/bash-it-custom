# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

### [Unreleased][unreleased]

#### removed
- remove alias_completion script

#### fixed
- replace `which "${cmd}"` by `command -v "${cmd}"` in waf command to look for an existing command
- fix which-alias_test.sh

#### Added
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