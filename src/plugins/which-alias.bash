#! /bin/bash
_waf_usage()
{
    printf %b "
    \e[1mUsage:\e[0m
        which_alias_for [OPTIONS] COMMAND
    \e[1mOptions:\e[0m
        -s      shorten alias list
        -h      display this message

    list all aliases related to the given COMMAND
"
}

_wai_usage()
{
    printf %b "
    \e[1mUsage:\e[0m
        which_alias_is [OPTIONS] COMMAND
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
    ${_waf_usage}
    _waf_docleanup
    return 0
}

_waf_warn()
{
    printf %b "\e[31m$1\e[0m"
}

_waf_fail()
{    
    _waf_warn "$1"
    ${_waf_usage}
    _waf_docleanup
    return 1
}

which_alias_for()
{
    local SHORT=0
    local OPTIONS=":hs"
    _waf_usage="_waf_usage"

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

    if command -v "${cmd}" &> /dev/null; then
        local result

        if ((${SHORT})); then
            result="$(alias | grep -Poe "${pattern}" | column -c 100)"
        else
            result="$(alias | grep --color=always -Pe "${pattern}")"
        fi
        if [ -n "${result}" ]; then
            printf %b "${result}"
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

which_alias_is()
{
    local SHORT=0
    local OPTIONS=":hs"
    _waf_usage="_wai_usage"

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

    local result
    local alias="$1"
    local pattern="(?<=alias ${alias}\=[\'\"])[^\'\"]+(?=[\'\"])"

    if [ -z "${alias}" ]; then
        _waf_fail "Please specify an alias name"
        return $?
    fi

    read result < <(alias | grep --color=always -Pe "${pattern}")

    if [ "$?" == "0" ]; then
        if ((${SHORT})); then
            result="$(printf %b "${result}" | grep -Poe "(?<=[\'\"])[^\'\"]+(?=[\'\"])")"
        fi
        printf %b "${result}"
    else
        _waf_warn "Alias does not exist: ${alias}"
    fi
    _waf_docleanup

    return 0
}

alias waf="which_alias_for"
alias wai="which_alias_is"