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

Verification
------------
Run `./check.sh` to execute the available verification workflow.

The script runs:
- `shellcheck` when available locally
- the `bats` suite from `tests/*.bats`

Requirements:
- `bats` must be installed locally
- `shellcheck` is optional but recommended

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
