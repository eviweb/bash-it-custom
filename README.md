Bash it - Custom
================
Some custom [bash-it](https://github.com/Bash-it/bash-it) files.

Installation
------------
Run `git clone https://github.com/eviweb/bash-it-custom && bash-it-custom/install.sh`  
Once the installation is complete, reload your Bash session.  
For example, run `exec bash -l` or `reload`.

> **Note**  
> For development, clone the repository locally:  
> `git clone https://github.com/eviweb/bash-it-custom`  
> Then run the test suite with `bash-it-custom/check.sh`.

Update
------
From the `./bash-it-custom` installation directory, run `./install.sh -U && reload`.

Uninstallation
--------------
From the `./bash-it-custom` installation directory, run `./install.sh -u`.

Dry Run
-------
Use `./install.sh -n` to preview install actions without modifying `$BASH_IT`.
Use `./install.sh -n -u` to preview uninstall actions.

Installer Output
----------------
`install.sh` now prints explicit action messages for install, update, uninstall,
dry-run operations, and unmanaged links that are intentionally preserved.

Installer Validation
--------------------
`install.sh` validates that `$BASH_IT` exists and contains the required
component directories: `aliases`, `completion`, `custom`, `lib`, and `plugins`.
It also fails fast when install or uninstall actions cannot be completed
because of filesystem permission errors.

Verification
------------
Run `./check.sh` to execute the available verification workflow.

The script runs:
- `shellcheck` when available locally
- the `bats` suite from `tests/*.bats`

Requirements:
- `bats` must be installed locally
- `shellcheck` is optional but recommended

Notes:
- generated completion code such as `src/completion/rustup.bash` is excluded from `shellcheck`

Customization Catalog
---------------------
### Aliases
* **bash-it**: bash-it command line aliases
* **env**: environment related aliases
* **git**: additional git aliases
* **kitchen**: test kitchen aliases
* **projects.plugin**: projects plugin additional aliases
* **python**: Python-related aliases

### Completion
* **bash-it**: reuse the `bash-it` completion definition for the `bit` alias
* **cargo**: cargo completion loaded from the active Rust toolchain
* **rustup**: rustup completion

### Custom
* **custom**: load custom files from the package entry points

### Lib
* **00-init**: initialize the shell environment before all

### Plugins
* **local-bashrc**: load local initialization files from `$HOME/.bashrc.d`
* **local-completion**: load local completion files from `$HOME/.bash_completion.d`
* **which-alias**:
    - `which_alias_for` | `waf`: list all related aliases to a given command
    - `which_alias_is` | `wai`: get the declaration of an alias if it exists

License
-------
This project is licensed under the terms of the [MIT License](LICENSE).
