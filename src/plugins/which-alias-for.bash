#! /bin/bash
which_alias_for()
{
    local SHORT=0
    local usage="
    Usage:
        ${FUNCNAME} [OPTIONS] COMMAND
    Options:        
        -s      shorten alias list
        -h      display this message
    list all aliases related to the given COMMAND
"
    local OPTIONS=":hs"

    OPTIND=1
    export GREP_COLORS='mt=01;95'
    
    while getopts ${OPTIONS} flag; do
        case $flag in
            s) SHORT=1;;
            \?) echo "Unknown flag: $OPTARG" && echo "${usage}" && return 1;;
            *) echo "${usage}" && return 0;;
        esac
    done
    shift $(($OPTIND - 1))

    local cmd="$1"
    local pattern="[^[:space:]]+(?=\=[\"\']${cmd})"
    if which "${cmd}" &> /dev/null; then
        if [ -n "${cmd}" ]; then
            if ((${SHORT})); then
                alias | grep -Poe "${pattern}" | column -c 100
            else
                alias | grep --color=always -Pe "${pattern}"
            fi
        else
            echo "No alias found for: ${cmd}"
        fi
    else
        echo "Command not found: ${cmd}" && echo "${usage}" && return 1
    fi
    unset GREP_COLORS

    return 0
}

alias waf="which_alias_for"