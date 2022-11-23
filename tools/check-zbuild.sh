#!/bin/bash

adir=$(dirname $(dirname $0))
cd $adir
pwd

if [[ ! -e objs/nginx ]]; then
	printf "\n\n --- exec tools/zbuild.sh first \n\n";
	exit 0;
fi

>/tmp/miss-nginx-modules.txt

find debian/modules/ -mindepth 1 -maxdepth 1 -type d  -print0 | \
while IFS= read -r -d '' adir; do
	adir=$(basename %$adir)

	#	exclude watch + patches + lua
	if [[ $adir == "watch" ]]; then continue; fi
	if [[ $adir == "patches" ]]; then continue; fi
	if [[ $adir == *"lua" ]]; then continue; fi

	if [[ $adir == *"waf"* ]]; then continue; fi
	if [[ $adir == *"uploadprogress"* ]]; then continue; fi

	printf "\n -- $adir "

	anum=$(objs/nginx -V 2>&1 | tr ' ' "\n" | grep -iv with | grep module | grep add | grep $adir | wc -l)
	printf " $anum"

	if [[ $anum -lt 1 ]]; then
		echo " $adir " >> /tmp/miss-nginx-modules.txt
	fi
done

printf "\n\n\n"
if [[ -s /tmp/miss-nginx-modules.txt ]]; then
	printf " --- missing modules : \n"
	cat /tmp/miss-nginx-modules.txt
else
	printf " --- NO missing modules \n"
fi
printf "\n\n\n"
