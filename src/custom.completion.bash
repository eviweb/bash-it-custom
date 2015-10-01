#! /bin/bash
custom_srcdir()
{
    echo "$(dirname $(readlink -f ${BASH_SOURCE}))"
}

. $(custom_srcdir)/loader.sh

loadCustomFrom "$(custom_srcdir)/completion"