#! /bin/bash
# local initialization scripts
if [[ -d $HOME/.bashrc.d ]]; then
    if [ -z "${BASHRC_INC}" ]; then
        BASHRC_INC=$HOME/.bashrc.d
    fi
    for i in $HOME/.bashrc.d/*.*sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi