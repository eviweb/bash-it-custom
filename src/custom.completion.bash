#! /bin/bash
resolve_custom_path()
{
    local target_path="$1"
    local dir_path link_target

    while [ -L "${target_path}" ]; do
        dir_path="${target_path%/*}"
        if [[ "${dir_path}" == "${target_path}" ]]; then
            dir_path="."
        elif [[ -z "${dir_path}" ]]; then
            dir_path="/"
        fi
        dir_path="$(cd -P -- "${dir_path}" && pwd)"
        link_target="$(readlink "${target_path}")"
        if [[ "${link_target}" = /* ]]; then
            target_path="${link_target}"
        else
            target_path="${dir_path}/${link_target}"
        fi
    done

    dir_path="${target_path%/*}"
    if [[ "${dir_path}" == "${target_path}" ]]; then
        dir_path="."
    elif [[ -z "${dir_path}" ]]; then
        dir_path="/"
    fi
    dir_path="$(cd -P -- "${dir_path}" && pwd)"
    printf '%s/%s\n' "${dir_path}" "${target_path##*/}"
}

custom_srcdir()
{
    local _resolved
    _resolved="$(resolve_custom_path "${BASH_SOURCE[0]}")"
    printf '%s\n' "${_resolved%/*}"
}

# Precompute source directory once to avoid redundant subshells
_CUSTOM_SRCDIR="$(custom_srcdir)"

# shellcheck source=src/loader.sh
. "${_CUSTOM_SRCDIR}/loader.sh"

loadCustomFrom "${_CUSTOM_SRCDIR}/completion"
if [ -d "${HOME}/.bash_completion.d" ]; then
    loadCustomFrom "${HOME}/.bash_completion.d"
fi

unset _CUSTOM_SRCDIR
