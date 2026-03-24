#! /bin/bash
custom_srcdir()
{
    dirname "$(readlink -f "${BASH_SOURCE[0]}")"
}

# shellcheck source=src/loader.sh
. "$(custom_srcdir)/loader.sh"

loadCustomFrom "$(custom_srcdir)/aliases"
