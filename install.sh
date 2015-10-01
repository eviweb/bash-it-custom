#! /bin/bash
UNINSTALL=0

# get bash it custom main directory
bash_it_custom_maindir()
{
    echo "$(dirname $(readlink -f ${BASH_SOURCE}))"
}

# installer usage
usage() {
    echo "
    Usage:
        ./install.sh [OPTIONS]
    Options:
        -u      uninstall bash-it-custom package from \$BASH_IT
        -h      display this message

    Install/uninstall bash-it-custom package to \$BASH_IT
"
}

# links provider
get_links()
{
    declare -A links=(
        ["custom.aliases.bash"]="aliases"
        ["custom.completion.bash"]="completion"
        ["custom.bash"]="lib"
        ["custom.plugins.bash"]="plugins"
    )

    declare -p links
}

# check whether a link can be removed
isUnlinkable()
{
    local realpath="$(readlink -f $1)"
    local unlinkable=1

    [ -h ${file} ] && 
        (echo "${realpath}" | grep "$(bash_it_custom_maindir)" &> /dev/null) &&
        unlinkable=0

    return ${unlinkable}
}

# install
install()
{
    local links
    eval $(get_links)

    for link in "${!links[@]}"; do
        ln -s $(bash_it_custom_maindir)/src/${link} ${BASH_IT}/${links[${link}]}/${link}
    done
}

# uninstall
uninstall()
{
    local links
    eval $(get_links)

    for link in "${!links[@]}"; do
        local file="${BASH_IT}/${links[${link}]}/${link}"
        isUnlinkable "${file}" && unlink ${file}
    done
}

OPTIONS=":hu"
# get command line options
while getopts $OPTIONS option
do
    case $option in
        u) UNINSTALL=1;;
        *) usage && exit 1;;
    esac
done
shift $(($OPTIND - 1 ))

if ((${UNINSTALL})); then
    uninstall
else
    install
fi
