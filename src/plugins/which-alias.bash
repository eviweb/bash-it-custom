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

_alias_parse_line()
{
    local line="$1"
    local name_ref="$2"
    local body_ref="$3"
    local parsed_name parsed_body quote

    line="${line%"${line##*[![:space:]]}"}"
    [[ "${line}" == alias\ *=* ]] || return 1

    parsed_name="${line#alias }"
    parsed_name="${parsed_name%%=*}"
    parsed_body="${line#*=}"
    quote="${parsed_body:0:1}"
    parsed_body="${parsed_body:1}"
    parsed_body="${parsed_body%"${quote}"}"

    printf -v "${name_ref}" '%s' "${parsed_name}"
    printf -v "${body_ref}" '%s' "${parsed_body}"

    return 0
}

_alias_body_matches_command()
{
    local body="$1"
    local cmd="$2"

    [[ "${body}" == "${cmd}" || "${body}" == "${cmd} "* ]]
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
    shift $((OPTIND - 1))

    local cmd="$1"
    if [ -z "${cmd}" ]; then
        _waf_fail "Please specify a command name"
        return $?
    fi

    if command -v "${cmd}" &> /dev/null; then
        local line name body result=""

        while IFS= read -r line; do
            _alias_parse_line "${line}" name body || continue
            _alias_body_matches_command "${body}" "${cmd}" || continue

            if ((SHORT)); then
                result+="${name}"$'\n'
            else
                result+="${line}"$'\n'
            fi
        done < <(alias)

        result="${result%$'\n'}"
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
    shift $((OPTIND - 1))

    local line result name body
    local alias="$1"

    if [ -z "${alias}" ]; then
        _waf_fail "Please specify an alias name"
        return $?
    fi

    while IFS= read -r line; do
        _alias_parse_line "${line}" name body || continue
        [ "${name}" = "${alias}" ] || continue

        if ((SHORT)); then
            result="${body}"
        else
            result="${line}"
        fi
        printf %b "${result}"
        _waf_docleanup
        return 0
    done < <(alias)

    _waf_warn "Alias does not exist: ${alias}"
    _waf_docleanup

    return 0
}

alias waf="which_alias_for"
alias wai="which_alias_is"
