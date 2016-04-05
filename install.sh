#! /bin/bash
UNINSTALL=0

# get bash it custom main directory
bash_it_custom_maindir()
{
    echo "$(dirname $(readlink -f ${BASH_SOURCE}))"
}

# get bash it custom updates directory
bash_it_custom_updatesdir()
{
    echo "$(bash_it_custom_maindir)/updates"
}

# installer usage
usage() {
    echo "
    Usage:
        ./install.sh [OPTIONS]
    Options:
        -U      update packages in \$BASH_IT
        -u      uninstall bash-it-custom package from \$BASH_IT
        -h      display this message

    Install/update/uninstall bash-it-custom package to \$BASH_IT
"
}

# links provider
get_links()
{
    declare -A links=(
        ["custom.aliases.bash"]="aliases"
        ["custom.completion.bash"]="completion"
        ["custom.bash"]="custom"
        ["custom.lib.bash"]="lib"
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

# check bash it installation dir
checkBashItDir()
{
    if [ -z "${BASH_IT}" ]; then
        echo "No bash-it installation found, abort." >&2
        exit 1
    fi
    if [ ! -e "${BASH_IT}" ]; then
        echo "Invalid path for bash-it: ${BASH_IT}, abort." >&2
        exit 1
    fi
}

# get updates
get_updates()
{
    ls -v $(bash_it_custom_updatesdir)
}

# apply update
apply_update()
{
    local update_file="$1"
    local filename="${update_file##*/}"
    local update_pattern="${filename%.*}"
    update="update_${update_pattern//./}"

    . "${update_file}"
    ${update}
}

# install
install()
{
    local links
    eval $(get_links)

    for link in "${!links[@]}"; do
        ln -fs $(bash_it_custom_maindir)/src/${link} ${BASH_IT}/${links[${link}]}/${link}
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

# update
update()
{
    local updates=( $(get_updates) )

    for update in "${updates[@]}"; do
        apply_update "$(bash_it_custom_updatesdir)/${update}"
    done
    install
}

OPTIONS=":huU"
# get command line options
while getopts $OPTIONS option
do
    case $option in
        u) UNINSTALL=1;;
        U) UPDATE=1;;
        *) usage && exit 1;;
    esac
done
shift $(($OPTIND - 1 ))

if ((${UNINSTALL})); then
    checkBashItDir && uninstall
elif ((${UPDATE})); then
    checkBashItDir && update
else
    checkBashItDir && install
fi
