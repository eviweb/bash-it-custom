#! /bin/bash
if complete -p bash-it > /dev/null 2>&1; then
  eval "$(complete -p bash-it | sed 's/ bash-it$/ bit/')"
fi
