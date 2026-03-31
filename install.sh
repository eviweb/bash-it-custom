#! /bin/bash
UNINSTALL=0
DRY_RUN=0

log_action()
{
    echo "$1"
}

resolve_path()
{
    local target_path="$1"
    local dir_path link_target

    while [ -L "${target_path}" ]; do
        dir_path="$(cd -P -- "$(dirname -- "${target_path}")" && pwd)"
        link_target="$(readlink "${target_path}")"
        if [[ "${link_target}" = /* ]]; then
            target_path="${link_target}"
        else
            target_path="${dir_path}/${link_target}"
        fi
    done

    dir_path="$(cd -P -- "$(dirname -- "${target_path}")" && pwd)"
    printf '%s/%s\n' "${dir_path}" "$(basename -- "${target_path}")"
}

# get bash it custom main directory
bash_it_custom_maindir()
{
    dirname "$(resolve_path "${BASH_SOURCE[0]}")"
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

required_component_dirs()
{
    printf '%s\n' aliases completion custom lib plugins
}

# check whether a link can be removed
isUnlinkable()
{
    local target="$1"
    local target_path
    local unlinkable=1

    target_path="$(resolve_path "${target}")"

    [ -h "${target}" ] &&
        [[ "${target_path}" = "$(bash_it_custom_maindir)"/* ]] &&
        unlinkable=0

    return ${unlinkable}
}

link_file()
{
    local source_file="$1"
    local target_file="$2"

    if ((DRY_RUN)); then
        echo "Would link ${target_file} -> ${source_file}"
    else
        ln -fs "${source_file}" "${target_file}" || return 1
    fi
}

unlink_file()
{
    local target_file="$1"

    if ((DRY_RUN)); then
        echo "Would unlink ${target_file}"
    else
        unlink "${target_file}" || return 1
    fi
}

skip_unmanaged_file()
{
    local target_file="$1"

    echo "Skipping unmanaged link ${target_file}"
}

fail_invalid_target()
{
    local target_file="$1"

    echo "Invalid managed target path: ${target_file} is a directory, abort." >&2
    return 1
}

# check bash it installation dir
checkBashItDir()
{
    local component_dir

    if [ -z "${BASH_IT}" ]; then
        echo "No bash-it installation found, abort." >&2
        exit 1
    fi
    if [ ! -e "${BASH_IT}" ]; then
        echo "Invalid path for bash-it: ${BASH_IT}, abort." >&2
        exit 1
    fi

    while IFS= read -r component_dir; do
        if [ ! -d "${BASH_IT}/${component_dir}" ]; then
            echo "Missing bash-it component directory: ${BASH_IT}/${component_dir}, abort." >&2
            exit 1
        fi
    done < <(required_component_dirs)
}

# get updates
get_updates()
{
    ls -v "$(bash_it_custom_updatesdir)"
}

# apply update
apply_update()
{
    local update_file="$1"
    local filename="${update_file##*/}"
    local update_pattern="${filename%.*}"
    update="update_${update_pattern//./}"

    # shellcheck source=/dev/null
    . "${update_file}"
    ${update}
}

# install
install()
{
    local links
    eval "$(get_links)"

    if ((DRY_RUN)); then
        log_action "Dry run: install into ${BASH_IT}"
    else
        log_action "Installing bash-it-custom into ${BASH_IT}"
    fi

    for link in "${!links[@]}"; do
        local target_file="${BASH_IT}/${links[${link}]}/${link}"

        if [ -d "${target_file}" ]; then
            fail_invalid_target "${target_file}" || return 1
        fi

        if ! link_file "$(bash_it_custom_maindir)/src/${link}" "${target_file}"; then
            return 1
        fi
    done

    return 0
}

# uninstall
uninstall()
{
    local links
    eval "$(get_links)"

    if ((DRY_RUN)); then
        log_action "Dry run: uninstall from ${BASH_IT}"
    else
        log_action "Uninstalling bash-it-custom from ${BASH_IT}"
    fi

    for link in "${!links[@]}"; do
        local file="${BASH_IT}/${links[${link}]}/${link}"

        if [ -d "${file}" ]; then
            fail_invalid_target "${file}" || return 1
        fi

        if isUnlinkable "${file}"; then
            if ! unlink_file "${file}"; then
                return 1
            fi
        elif [ -h "${file}" ]; then
            skip_unmanaged_file "${file}"
        fi
    done

    return 0
}

# update
update()
{
    local updates=()

    mapfile -t updates < <(get_updates)

    if ((DRY_RUN)); then
        log_action "Dry run: update in ${BASH_IT}"
    else
        log_action "Updating bash-it-custom in ${BASH_IT}"
    fi

    for update in "${updates[@]}"; do
        apply_update "$(bash_it_custom_updatesdir)/${update}"
    done
    install || return 1

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
shift $((OPTIND - 1))

if ((UNINSTALL)); then
    checkBashItDir && uninstall
elif ((UPDATE)); then
    checkBashItDir && update
else
    checkBashItDir && install
fi
