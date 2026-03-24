#! /bin/bash
UNINSTALL=0
DRY_RUN=0

log_action()
{
    echo "$1"
}

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
        -n      dry run, print actions without modifying \$BASH_IT
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
    local target="$1"
    local realpath="$(readlink -f "$target")"
    local unlinkable=1

    [ -h "${target}" ] &&
        (echo "${realpath}" | grep "$(bash_it_custom_maindir)" &> /dev/null) &&
        unlinkable=0

    return ${unlinkable}
}

link_file()
{
    local source_file="$1"
    local target_file="$2"

    if ((${DRY_RUN})); then
        echo "Would link ${target_file} -> ${source_file}"
    else
        ln -fs "${source_file}" "${target_file}"
    fi
}

unlink_file()
{
    local target_file="$1"

    if ((${DRY_RUN})); then
        echo "Would unlink ${target_file}"
    else
        unlink "${target_file}"
    fi
}

skip_unmanaged_file()
{
    local target_file="$1"

    echo "Skipping unmanaged link ${target_file}"
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
    eval "$(get_links)"

    if ((${DRY_RUN})); then
        log_action "Dry run: install into ${BASH_IT}"
    else
        log_action "Installing bash-it-custom into ${BASH_IT}"
    fi

    for link in "${!links[@]}"; do
        link_file "$(bash_it_custom_maindir)/src/${link}" "${BASH_IT}/${links[${link}]}/${link}"
    done

    return 0
}

# uninstall
uninstall()
{
    local links
    eval "$(get_links)"

    if ((${DRY_RUN})); then
        log_action "Dry run: uninstall from ${BASH_IT}"
    else
        log_action "Uninstalling bash-it-custom from ${BASH_IT}"
    fi

    for link in "${!links[@]}"; do
        local file="${BASH_IT}/${links[${link}]}/${link}"
        if isUnlinkable "${file}"; then
            unlink_file "${file}"
        elif [ -h "${file}" ]; then
            skip_unmanaged_file "${file}"
        fi
    done

    return 0
}

# update
update()
{
    local updates=( $(get_updates) )

    if ((${DRY_RUN})); then
        log_action "Dry run: update in ${BASH_IT}"
    else
        log_action "Updating bash-it-custom in ${BASH_IT}"
    fi

    for update in "${updates[@]}"; do
        apply_update "$(bash_it_custom_updatesdir)/${update}"
    done
    install

    return 0
}

OPTIONS=":hnuU"
# get command line options
while getopts $OPTIONS option
do
    case $option in
        n) DRY_RUN=1;;
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
