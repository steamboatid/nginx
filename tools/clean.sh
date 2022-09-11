#!/bin/bash

adir=$(dirname $0)
cd $adir/..

fakeroot debian/rules clean
rm -rf objs

find debian -type f \( -iname "*.*inst" -or -iname "*.*rm" \) -exec chmod -x {} \;

[[ -d .git ]] && git add . >/dev/null 2>&1 &
