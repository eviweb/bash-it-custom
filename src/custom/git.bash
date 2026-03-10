#! /bin/bash

git_add_modified()
{
    ga $(gs | grep -Pe "modified:.*" | grep -Poe "(?<=modified:   )([^ ]+)" | tr "\n" " ")
}

gax()
{
    if [ $# -eq 0 ]; then
        git add .
    else
        git add -- . $(printf ":!%s " "$@")
    fi
}
