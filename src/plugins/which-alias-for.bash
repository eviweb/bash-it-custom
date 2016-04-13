#! /bin/bash
_waf_usage()
{
    echo -e "
    \e[1mUsage:\e[0m
        ${FUNCNAME} [OPTIONS] COMMAND
    \e[1mOptions:\e[0m
        -s      shorten alias list
        -h      display this message

    list all aliases related to the given COMMAND
"
}

_waf_docleanup()
{
    unset GREP_COLORS
}

_waf_help()
{
    _waf_usage
    _waf_docleanup
    return 0
}

_waf_warn()
{
    echo -e "\e[31m$1\e[0m"
}

_waf_fail()
{    
    _waf_warn "$1"
    _waf_usage
    _waf_docleanup
    return 1
}

which_alias_for()
{
    local SHORT=0
    local OPTIONS=":hs"

    OPTIND=1
    export GREP_COLORS='mt=01;95'
    
    while getopts ${OPTIONS} flag; do
        case $flag in
            s)  SHORT=1;;
            \?) _waf_fail "Unknown flag: $OPTARG"
                return $?;;
            *)  _waf_help
                return $?;;
        esac
    done
    shift $(($OPTIND - 1))

    local cmd="$1"
    local pattern="[^[:space:]]+(?=\=[\"\']${cmd})"

    if [ -z "${cmd}" ]; then
        _waf_fail "Please specify a command name"
        return $?
    fi

    if which "${cmd}" &> /dev/null; then
        if [ -n "${cmd}" ]; then
            if ((${SHORT})); then
                alias | grep -Poe "${pattern}" | column -c 100
            else
                alias | grep --color=always -Pe "${pattern}"
            fi
        else
            _waf_warn "No alias found for: ${cmd}"           
        fi
    else
        _waf_fail "Command not found: ${cmd}"
        return $?
    fi
    _waf_docleanup

    return 0
}

alias waf="which_alias_for"