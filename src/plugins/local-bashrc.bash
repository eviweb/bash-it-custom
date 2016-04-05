#! /bin/bash
# local initialization scripts
if [ -z "${BASHRC_INC}" ]; then
    BASHRC_INC=$HOME/.bashrc.d
fi
if [[ -d ${BASHRC_INC} ]]; then    
    for i in ${BASHRC_INC}/*.*sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi