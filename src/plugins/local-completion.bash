#! /bin/bash
# local bash completion files
if [ -z "${BASH_COMPLETION_INC}" ]; then
    BASH_COMPLETION_INC=$HOME/.bash_completion.d
fi
if [[ -d ${BASH_COMPLETION_INC} ]]; then
    for i in ${BASH_COMPLETION_INC}/*.*sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi