#!/bin/bash

cd /root/github/nginx
#root_path=$(pwd)
#for submodule in $(find -mindepth 2 -type d -name .git); do
##	submodule_dir=$root_path/$submodule/..
#	submodule_dir=$submodule/..
#	remote_name=$(cd $submodule_dir && git rev-parse --abbrev-ref --symbolic-full-name @{u}|cut -d'/' -f1 )
#	remote_uri=$(cd $submodule_dir && git remote get-url $remote_name)
#
#	printf "\n\nAdding $submodule $remote_uri \n\twith remote=$remote_name -- dir=$submodule_dir \n"
#
#	# If already added to index, but not to .gitmodules...
#	git rm --cached $submodule_dir &> /dev/null
#
#	git submodule add $remote_uri $submodule_dir
#	git add $submodule_dir
#done


for x in $(find . -type d) ; do
	if [ -d "${x}/.git" ] ; then
		cd "${x}"
		origin="$(git config --get remote.origin.url)"
		cd - 1>/dev/null

		printf "\n\nAdding ${x} \n"
		git submodule add "${origin}" "${x}"
		git add "${x}"
	fi
done

printf "\n\n see .gitmodules file \n\n"
