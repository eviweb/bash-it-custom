#! /bin/bash
# local bash completion files
if [[ -d ${HOME}/.bash_completion.d ]]; then
    for i in ${HOME}/.bash_completion.d/*.*sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi