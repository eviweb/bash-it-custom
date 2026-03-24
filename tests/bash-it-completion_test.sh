#! /bin/bash

################ Utilities #################
me()
{
    echo "$(readlink -f $BASH_SOURCE)"
}

mydir()
{
    echo "$(dirname $(me))"
}

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

srcdir()
{
    echo "$(maindir)/src"
}

qatestdir()
{
    echo "$(maindir)/tests"
}

libdir()
{
    echo "$(maindir)/lib"
}

############## End Utilities ###############
. $(libdir)/shell-testlib/bootstrap.sh

use "envbuilder"

supportdir()
{
    echo "$(qatestdir)/support"
}

load "$(supportdir)/common.sh"

################ Unit tests ################
testBitCompletionReusesBashItCompletionDefinition()
{
    _bash-it()
    {
        return 0
    }

    complete -r bash-it bit 2> /dev/null
    complete -o bashdefault -o default -F _bash-it bash-it

    . "$(srcdir)/completion/bash-it.bash"

    local expected
    expected="$(complete -p bash-it | sed 's/ bash-it$/ bit/')"

    assertEquals "bit completion should mirror bash-it completion" "${expected}" "$(complete -p bit)"
}

testBitCompletionDoesNothingWhenBashItCompletionIsMissing()
{
    complete -r bash-it bit 2> /dev/null

    . "$(srcdir)/completion/bash-it.bash"

    assertFalse "bit completion should remain undefined" "complete -p bit > /dev/null 2>&1"
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

path=$(findShunit2 "$BASH_SOURCE")
code=$?
if [ ${code} -ne 0 ]; then
    exitOnError ${code} "${path}"
fi
. "${path}"/source/2.1/src/shunit2
