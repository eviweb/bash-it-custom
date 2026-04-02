#! /bin/bash
UNINSTALL=0
DRY_RUN=0
CHECK_ONLY=0
UPDATE_ONLY=0
ACTION="install"

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
        -c, --check validate the current \$BASH_IT setup without modifying it
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

status_for_target()
{
    local target_file="$1"
    local managed_source="$2"
    local target_path

    if [ -d "${target_file}" ]; then
        printf '%s\n' "ERROR: ${target_file#"${BASH_IT}/"} -> directory"
        return 1
    fi

    if [ ! -e "${target_file}" ] && [ ! -L "${target_file}" ]; then
        printf '%s\n' "INFO: ${target_file#"${BASH_IT}/"} -> missing"
        return 0
    fi

    if [ -L "${target_file}" ]; then
        target_path="$(resolve_path "${target_file}")"
        if [ "${target_path}" = "${managed_source}" ]; then
            printf '%s\n' "OK: ${target_file#"${BASH_IT}/"} -> managed link"
            return 0
        fi
        if [[ "${target_path}" = "$(bash_it_custom_maindir)"/* ]]; then
            printf '%s\n' "WARN: ${target_file#"${BASH_IT}/"} -> broken managed symlink"
            return 0
        fi
        printf '%s\n' "WARN: ${target_file#"${BASH_IT}/"} -> external symlink"
        return 0
    fi

    printf '%s\n' "WARN: ${target_file#"${BASH_IT}/"} -> regular file"
    return 0
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

check()
{
    local links
    local component_dir
    local has_errors=0

    if [ -z "${BASH_IT}" ]; then
        echo "No bash-it installation found, abort." >&2
        return 1
    fi

    if [ ! -e "${BASH_IT}" ]; then
        echo "Invalid path for bash-it: ${BASH_IT}, abort." >&2
        return 1
    fi

    eval "$(get_links)"

    echo "Checking bash-it-custom in ${BASH_IT}"

    while IFS= read -r component_dir; do
        if [ ! -d "${BASH_IT}/${component_dir}" ]; then
            echo "ERROR: missing component directory: ${BASH_IT}/${component_dir}"
            has_errors=1
        fi
    done < <(required_component_dirs)

    for link in "${!links[@]}"; do
        local target_file="${BASH_IT}/${links[${link}]}/${link}"
        local source_file

        source_file="$(bash_it_custom_maindir)/src/${link}"

        if ! status_for_target "${target_file}" "${source_file}"; then
            has_errors=1
        fi
    done

    if ((has_errors)); then
        echo "Check failed"
        return 1
    fi

    echo "Check passed"
    return 0
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

normalize_long_options()
{
    local normalized_args=()
    local arg

    for arg in "$@"; do
        case "${arg}" in
            --check) normalized_args+=("-c");;
            *) normalized_args+=("${arg}");;
        esac
    done

    printf '%s\n' "${normalized_args[@]}"
}

parse_arguments()
{
    local normalized_args=()
    local option

    mapfile -t normalized_args < <(normalize_long_options "$@")

    OPTIND=1
    while getopts ":chnuU" option "${normalized_args[@]}"; do
        case "${option}" in
            c) CHECK_ONLY=1;;
            h) usage
               return 1;;
            n) DRY_RUN=1;;
            u) UNINSTALL=1;;
            U) UPDATE_ONLY=1;;
            *) usage
               return 1;;
        esac
    done

    if ((CHECK_ONLY)); then
        ACTION="check"
    elif ((UNINSTALL)); then
        ACTION="uninstall"
    elif ((UPDATE_ONLY)); then
        ACTION="update"
    else
        ACTION="install"
    fi

    return 0
}

run_action()
{
    case "${ACTION}" in
        check)
            check
            ;;
        uninstall)
            checkBashItDir && uninstall
            ;;
        update)
            checkBashItDir && update
            ;;
        install)
            checkBashItDir && install
            ;;
    esac
}

parse_arguments "$@" && run_action
