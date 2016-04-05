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
testInstall()
{
    local files
    eval "$(fileProvider)"

    runInstaller

    for file in "${files[@]}"; do
        assertTrue "${file/$(dirname ${BASH_IT})\//} exists" "[ -h ${file} ]"

        local realfile="$(readlink -f ${file})"
        assertTrue "The real file exists" "[ -e ${realfile} ]"
    done
}

testUninstall()
{
    local files
    eval "$(fileProvider)"

    runInstaller
    runInstaller -u

    for file in "${files[@]}"; do
        assertFalse "${file/$(dirname ${BASH_IT})\//} should not exist anymore" "[ -h ${file} ]"
    done
}

testUninstallerShouldOnlyRemoveLinksThatPointToThisLib()
{
    local file="${HOME}/custom.aliases.bash"
    touch ${file}
    ln -s ${file} ${BASH_IT}/aliases

    runInstaller -u

    assertTrue "${file} still exists" "[ -h ${BASH_IT}/aliases/${file##*/} ]"
}

testInstallerShouldCheckBashItGlobalVar()
{
    local expected="No bash-it installation found, abort."
    unset BASH_IT

    assertFalse "installation should fail" "runInstaller > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "no message to standard output" "$(cat ${FSTDOUT})"
    assertSame "the expected message is displayed" "${expected}" "$(cat ${FSTDERR})"

    assertFalse "installation should fail" "runInstaller -u > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "no message to standard output" "$(cat ${FSTDOUT})"
    assertSame "the expected message is displayed" "${expected}" "$(cat ${FSTDERR})"
}

testInstallerShouldCheckBashItCorrectPath()
{
    export BASH_IT="/wrong/path"
    local expected="Invalid path for bash-it: ${BASH_IT}, abort."

    assertFalse "installation should fail" "runInstaller > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "no message to standard output" "$(cat ${FSTDOUT})"
    assertSame "the expected message is displayed" "${expected}" "$(cat ${FSTDERR})"

    assertFalse "installation should fail" "runInstaller -u > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "no message to standard output" "$(cat ${FSTDOUT})"
    assertSame "the expected message is displayed" "${expected}" "$(cat ${FSTDERR})"
}

testInstallerCanBeRunTwice()
{
    local files
    eval "$(fileProvider)"

    runInstaller

    assertTrue "installation can be run twice" "runInstaller > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "no message to standard error" "$(cat ${FSTDERR})"
    for file in "${files[@]}"; do
        assertTrue "${file/$(dirname ${BASH_IT})\//} exists" "[ -h ${file} ]"

        local realfile="$(readlink -f ${file})"
        assertTrue "The real file exists" "[ -e ${realfile} ]"
    done
}

testInstallerUsage()
{
    local expected="Usage:"

    assertEquals "usage is printed" "${expected}" "$(runInstaller -h | grep -o ${expected})"
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
