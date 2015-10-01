Bash it - Custom
================
Some custom [bash-it](https://github.com/Bash-it/bash-it) files.

##### Health status
[![Travis CI - Build Status](https://travis-ci.org/eviweb/bash-it-custom.svg)](https://travis-ci.org/eviweb/bash-it-custom)
[![Github - Last tag](https://img.shields.io/github/tag/eviweb/bash-it-custom.svg)](https://github.com/eviweb/bash-it-custom/tags)

Installation
------------
run `git clone https://github.com/eviweb/bash-it-custom && bash-it-custom/install.sh`    
Once ready to use, you will need to reload your bash session.    
This can be done by running `exec bash -l` for example, or `reload`.   

> **Note**    
> Please consider the default installation process described above for production.   
> If you are interested to install the development dependencies, add the `--recursive` flag to the clone command:    
> ie. `git clone --recursive https://github.com/eviweb/bash-it-custom`    
> Then you should be able to run the test suite `bash-it-custom/tests/testsuite.sh`   

Uninstallation
--------------
under the `./bash-it-custom` installation directory, run `./install.sh -u`

Customization Catalog
---------------------
### Aliases
* bash-it: bash-it command line aliases
* git: additional git aliases

### Completion
* bash-it: bash-it completion for the `bit` shortcut

### Plugins
* local-completion: load local completion files from `$HOME/.bash_completion.d`

License
-------
this project is licensed under the terms of the [MIT License](/LICENSE)
