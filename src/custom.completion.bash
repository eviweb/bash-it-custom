#! /bin/bash
resolve_custom_path()
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

custom_srcdir()
{
    dirname "$(resolve_custom_path "${BASH_SOURCE[0]}")"
}

# shellcheck source=src/loader.sh
. "$(custom_srcdir)/loader.sh"

loadCustomFrom "$(custom_srcdir)/completion"
if [ -d "${HOME}/.bash_completion.d" ]; then
    loadCustomFrom "${HOME}/.bash_completion.d"
fi
