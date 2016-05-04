#! /bin/bash

################ Utilities #################
# get the full name of this script
me()
{
    echo "$(readlink -f $BASH_SOURCE)"
}

# get the path of parent directory of this script
mydir()
{
    echo "$(dirname $(me))"
}

# get the path of the project main directory
maindir()
{
    local curdir="$(mydir)"

    while \
        [ ! -e "${curdir}/lib" ] && \
        [ ! -e "${curdir}/src" ] && \
        [ ! -e "${curdir}/tests" ] && \
        [ "${curdir}" != "/" ]; do

        curdir="$(dirname ${curdir})"
    done

    echo "${curdir}"
}

# get the path of the source directory
srcdir()
{
    echo "$(maindir)/src"
}

# get the path of the test directory
qatestdir()
{
    echo "$(maindir)/tests"
}

# get the path of the main lib directory
libdir()
{
    echo "$(maindir)/lib"
}

############## End Utilities ###############
. $(libdir)/shell-testlib/bootstrap.sh

load "$(srcdir)/plugins/which-alias.bash"
############# Custom Utilities #############
new_stub()
{
    local name="$1"
    local body="${2:-:}"
    shift

    eval "${name}() { "$@"; }"
}

stub_alias()
{
    new_stub "alias" "printf %b \""$@"\""
}

unstub()
{
    unset -f "$@"
}

remove_style()
{
    local pattern="s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"

    printf %b "$1" | sed -r "${pattern}"
}

remove_trailing_eof()
{
    local check="$(printf %s "${1: -1}" | tr "\n" "#")" # detect eof when using pipe
    local pattern='s/[[:space:]]$//'
    [ "${check: -1}" == "#" ] && pattern='s/#$//'

    printf %s "$1" | sed -e "${pattern}"
}

remove_columns()
{
    printf %s "$1" | grep -Pe [^=] | column -t -c 1 | sed 's/\s*//g'
}

sanitize_command()
{
    printf %b "$(remove_style "$(remove_trailing_eof "$($@)")")"
}

sanitized_waf()
{
    printf %b "$(sanitize_command "which_alias_for" $@)"
}

sanitized_wali()
{
    printf %b "$(sanitize_command "which_alias_is" $@)"
}

assertUsageDisplayed()
{
    local cmd="$1"
    local expected="usage ${cmd}"
    local actual="$(${cmd} -h | grep -iPoe "${cmd}|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "${cmd} displays its help usage" "${expected}" "$(remove_trailing_eof "${actual}")"
}

assertUnkownFlagError()
{
    local cmd="$1"
    local flag="$2"
    [ -z "${flag}" ] && flag="x"
    local expected="unknown flag: ${flag} usage"
    local actual="$(${cmd} -${flag} | grep -iPoe "unknown flag: ${flag}|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "${cmd} does not recognize flag: ${flag}" "${expected}" "$(remove_trailing_eof "${actual}")"
}

command_provider()
{
    declare -A commands=(
        [waf]="which_alias_for"
        [wai]="which_alias_is"
    )

    declare -p commands
}
################ Unit tests ################
testWafListsAliasesForAGivenCommand()
{
    local cmd="cmd"
    local aliases=(
        "alias a='${cmd}'"
        "\\nalias b='${cmd}'"
        "\\nalias c='fake'"
        "\\nalias d='${cmd}'"
        "\\nalias e='fake'"
    )
    local expected=(
        "alias a='${cmd}'"
        "\\nalias b='${cmd}'"
        "\\nalias d='${cmd}'"
    )
    stub_alias "${aliases[@]}"

    assertSame "all aliases are correctly found" "$(printf %b "${expected[@]}")" "$(sanitized_waf "${cmd}")"
}

testWafShortenAliasListToAliasNames()
{
    local cmd="cmd"
    local aliases=(
        "alias a='${cmd}'"
        "\\nalias b='${cmd}'"
        "\\nalias c='fake'"
        "\\nalias d='${cmd}'"
        "\\nalias e='fake'"
    )
    local expected="abd"

    stub_alias "${aliases[@]}"

    assertSame "only alias names are displayed" "${expected}" "$(remove_columns "$(sanitized_waf -s "${cmd}")")"
}

testWafNoCommandNameErrors()
{
    local expected="command name usage"
    local actual="$(which_alias_for | grep -iPoe "command name|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "no command name specified" "${expected}" "$(remove_trailing_eof "${actual}")"
}

testWafCommandNotFoundErrors()
{
    new_stub "which" "return 1"
    local cmd="not_exists"
    local expected="command not found: ${cmd} usage"
    local actual="$(which_alias_for "${cmd}" | grep -iPoe "command not found: ${cmd}|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "command not found" "${expected}" "$(remove_trailing_eof "${actual}")"
}

testWafAliasNotFoundErrors()
{
    local cmd="cmd"
    local aliases=(
        "alias a='fake'"
        "\\nalias b='fake'"
    )
    local expected="abd"

    stub_alias "${aliases[@]}"

    local expected="no alias found for: ${cmd}"
    local actual="$(which_alias_for "${cmd}" | grep -iPoe "no alias found for: ${cmd}" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "alias not found" "${expected}" "$(remove_trailing_eof "${actual}")"
}

testWaliGetTheFullAliasDeclarationOfAGivenAlias()
{
    local cmd="cmd"
    local alias="a"
    local aliases=(
        "alias a='${cmd}'"
        "\\nalias aa='fake'"
        "\\nalias aaba='fake'"
    )
    local expected="alias a='${cmd}'"

    stub_alias "${aliases[@]}"

    assertSame "the alias declaration is found" "$(printf %b "${expected[@]}")" "$(sanitized_wali "${alias}")"
}

testWaliGetTheShortAliasDeclarationOfAGivenAlias()
{
    local cmd="cmd"
    local alias="a"
    local aliases=(
        "alias a='${cmd} --flag'"
        "\\nalias aa='fake'"
        "\\nalias aaba='fake'"
    )
    local expected="${cmd} --flag"

    stub_alias "${aliases[@]}"

    assertSame "the short declaration is found" "$(printf %b "${expected[@]}")" "$(sanitized_wali -s "${alias}")"
}

testWaliNoAliasNameErrors()
{
    local expected="alias name usage"
    local actual="$(which_alias_is | grep -iPoe "alias name|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "no alias name specified" "${expected}" "$(remove_trailing_eof "${actual}")"
}

testWaliAliasNotExistsErrors()
{
    local aliases=(
        "alias b='fake'"
        "\\nalias c='fake'"
    )
    stub_alias "${aliases[@]}"
    local alias="not_exists"
    local expected="alias does not exist: ${alias} usage"
    local actual="$(which_alias_is "${alias}" | grep -iPoe "alias does not exist: ${alias}|usage" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
    assertSame "alias does not exist" "${expected}" "$(remove_trailing_eof "${actual}")"
}

testDisplayUsage()
{
    local commands
    eval "$(command_provider)"

    for cmd in "${commands[@]}"; do
        assertUsageDisplayed "${cmd}"
    done
}

testUnknowFlagErrors()
{
    local commands
    eval "$(command_provider)"

    for cmd in "${commands[@]}"; do
        assertUnkownFlagError "${cmd}"
    done
}

testGrepColorsAreCleaned()
{
    local commands
    eval "$(command_provider)"

    for cmd in "${commands[@]}"; do
        ${cmd} &>/dev/null
        assertNull "${cmd} unset correctly GREP_COLORS global variable" "${GREP_COLORS}"
    done
}

testCommandAliases()
{
    local commands
    eval "$(command_provider)"

    for alias in "${!commands[@]}"; do
        local command="${commands[$alias]}"
        local pattern="alias $alias=[\'\"]${command}[\'\"]"
        assertTrue "${alias} -> ${command}" "$(alias | grep -Poe "${pattern}")"
    done
}
###### Setup / Teardown #####
setUp()
{
    new_stub "which" "echo \"\$1\"; return 0"
}

tearDown()
{
    unstub "alias" "which"
}
################ RUN shunit2 ################
findShunit2()
{
    local curdir=$(dirname $(readlink -f "$1"))
    while [ ! -e "${curdir}/lib/shunit2" ] && [ "${curdir}" != "/" ]; do
        curdir=$(dirname ${curdir})
    done

    if [ "${curdir}" == "/" ]; then
        echo "Error Shunit2 not found !" >&2
        exit 1
    fi

    echo "${curdir}/lib/shunit2"
}

exitOnError()
{
    echo "$2" >&2
    exit $1
}
#
path=$(findShunit2 "$BASH_SOURCE")
code=$?
if [ ${code} -ne 0 ]; then
    exitOnError ${code} "${path}"
fi
. "${path}"/source/2.1/src/shunit2
#
# version: 0.2.2
