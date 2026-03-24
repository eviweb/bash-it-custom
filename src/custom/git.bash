#! /bin/bash

git_add_modified()
{
    local modified_files

    modified_files="$(gs | grep -Pe "modified:.*" | grep -Poe "(?<=modified:   )([^ ]+)" | tr "\n" " ")"
    # shellcheck disable=SC2086
    ga ${modified_files}
}

gax()
{
    if [ $# -eq 0 ]; then
        git add .
    else
        # shellcheck disable=SC2046
        git add -- . $(printf ":!%s " "$@")
    fi
}
