if command -v rustc >/dev/null 2>&1; then
    cargo() {
        unset -f cargo
        local _sysroot
        _sysroot="$(rustc --print sysroot)"
        if [[ -f "${_sysroot}/etc/bash_completion.d/cargo" ]]; then
            # shellcheck source=/dev/null
            source "${_sysroot}/etc/bash_completion.d/cargo"
        fi
        cargo "$@"
    }
fi
