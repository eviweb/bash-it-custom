#! /bin/bash

# load customization files from a given location
# @param string $1 location from which load customization files
loadCustomFrom()
{
    local customdir="$1"
    local custom
    local nullglob_was_set=0

    if [ ! -e "${customdir}" ]; then
        echo "The given location '${customdir}' does not exist, abort;" >&2
        return 1
    fi

    shopt -q nullglob && nullglob_was_set=1
    shopt -s nullglob

    for custom in "${customdir}"/*; do
        if [[ ${custom} =~ \.bash ]]; then
            # shellcheck source=/dev/null
            . "${custom}"
        fi
    done

    if [ "${nullglob_was_set}" -eq 0 ]; then
        shopt -u nullglob
    fi

    return 0
}
