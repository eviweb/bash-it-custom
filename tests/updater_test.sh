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

use "envbuilder"

############# Custom Utilities #############
supportdir()
{
    echo "$(qatestdir)/support"
}

load "$(supportdir)/*"

################ Unit tests ################
testApplyUpdate_011()
{
    local files
    local removed=(
        "lib/custom.bash"
    )
    eval "$(fileProvider)"

    for file in "${removed[@]}"; do
        ln -s "$(srcdir)/${file##*/}" "${BASH_IT}/${file}"
    done
    runInstaller -U

    for file in "${removed[@]}"; do
        assertFalse "${BASH_IT}/${file} removed" "[ -h ${BASH_IT}/${file} ]"
    done
    for file in "${files[@]}"; do
        assertTrue "${file/$(dirname ${BASH_IT})\//} exists" "[ -h ${file} ]"

        local realfile="$(readlink -f ${file})"
        assertTrue "The real file exists" "[ -e ${realfile} ]"
    done
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
