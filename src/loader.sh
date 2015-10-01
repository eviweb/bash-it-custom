#! /bin/bash

# load customization files from a given location
# @param string $1 location from which load customization files
loadCustomFrom()
{
    local customdir="$1"

    if [ ! -e "${customdir}" ]; then
        echo "The given location '${customdir}' does not exist, abort;" >&2
        exit 1
    fi

    for custom in ${customdir}/*.bash; do
        . "${custom}"
    done
}