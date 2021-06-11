#! /bin/bash

git_add_modified()
{
    ga $(gs | grep -Pe "modified:.*" | grep -Poe "(?<=modified:   )([^ ]+)" | tr "\n" " ")
}
