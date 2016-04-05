# installer test support library
setUp()
{    
    OLDPWD="$PWD"
    export OLDBASH_IT="$BASH_IT"
    prepareTestEnvironment
    newFakeBashItDir
}

tearDown()
{
    deleteBashItDir
    cd "$OLDPWD"
    export BASH_IT="${OLDBASH_IT}"
}

newFakeBashItDir()
{
    mkdir -p ${HOME}/.bash_it/{lib,custom,aliases,plugins,completion}
    export BASH_IT="${HOME}/.bash_it"
}

deleteBashItDir()
{
    rm -rf "${ENVBUILDER_TEMPDIR}/.bash_it"
}

runInstaller()
{
    $(maindir)/install.sh "$@"
}

fileProvider()
{
    declare -a files=(
        ${BASH_IT}/aliases/custom.aliases.bash
        ${BASH_IT}/completion/custom.completion.bash
        ${BASH_IT}/custom/custom.bash
        ${BASH_IT}/lib/custom.lib.bash
        ${BASH_IT}/plugins/custom.plugins.bash
    )

    declare -p files
}