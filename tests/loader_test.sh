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
load $(srcdir)/loader.sh

################ Unit tests ################
testLoader()
{
    newFixture "dummy1"
    newFixture "dummy2"

    loadCustomFrom "${HOME}"
    assertSame "The file is loaded and dummy1_test() is usable" "dummy1 is loaded." "$(dummy1_test)"
    assertSame "The file is loaded and dummy2_test() is usable" "dummy2 is loaded." "$(dummy2_test)"
}

testLoaderShouldComplainIfTheGivenLocationDoesNotExists()
{
    local dir="/non/existing/path"
    local expected="The given location '${dir}' does not exist, abort;"    

    assertFalse "The load process is aborted" "loadCustomFrom ${dir} > ${FSTDOUT} 2> ${FSTDERR}"
    assertNull "No message in the standard output" "$(cat ${FSTDOUT})"
    assertSame "The error message is displayed through the standard error" "${expected}" "$(cat ${FSTDERR})"
}

testLoaderShouldNotComplainIfTheLocationIsEmpty()
{
    loadCustomFrom "${HOME}"
    assertNull "No message in the standard output" "$(cat ${FSTDOUT})"
    assertNull "No message in the standard error" "$(cat ${FSTDERR})"
}

###### Setup / Teardown #####
oneTimeSetUp()
{
    newTestDir
    changeHomeDir "${ENVBUILDER_TEMPDIR}"
}

oneTimeTearDown()
{
    removeTestDir
    revertHomeDir
}

setUp()
{    
    OLDPWD="$PWD"
    prepareTestEnvironment
}

tearDown()
{
    cd "$OLDPWD"
}

newFixture()
{
    local file="${1%.*}"

    [ -z "${file}" ] && file="dummy"

    echo "${file}_test() { echo \"${file} is loaded.\"; }" > ${HOME}/${file}.bash
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
