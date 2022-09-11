#!/bin/bash



get_md5(){
	echo "$1" | md5sum | awk '{print $1}'
}

get_curl(){
	aurl="$1"
	cache_file=$(get_md5 "$aurl")
	cache_file="/tmp/cache-curl-$cache_file.txt"

	docurl=0
	if [[ ! -f "$cache_file" ]]; then
		docurl=1
	else
		date_file=$(date -r "$cache_file" "+%s")
		date_now=$(date "+%s")

		date_file=$(( $date_file ))
		date_now=$(( $date_now ))
		date_delta=$(( $date_now - $date_file ))

		if [[ $date_delta -gt 3600 ]]; then
			docurl=1
		fi
	fi

	if [[ $docurl -gt 0 ]]; then
		curl -L --insecure --ipv4 -A "Aptly/1.0" "$aurl" 2>&1 >$cache_file
	fi
	# printf "\n curl -L --insecure --ipv4 -A Aptly/1.0 $aurl \n -- $cache_file \n"

	cat $cache_file
}

get_commit_lastdate(){
	agit="$1"
	rfile="$2"

	#git_url = https://api.github.com/repos/openresty/lua-resty-lrucache/commits?page=1&per_page=1
	aurl="https://api.github.com/repos/$agit/commits?page=1&per_page=1"
	home_url="https://github.com/$agit"

	# gmt_date=$(get_curl "$aurl" | python3 -m json.tool |\
	# grep -i "date" | sed -r 's/\"//g' | sort -u | head -n1 | sed -r 's/\s+/ /g' |\
	# cut -d' ' -f3-)
	html_url=$(get_curl "$aurl" | jq -r '.[0].html_url')
	sha_full=$(get_curl "$aurl" | jq -r '.[0].sha')
	sha_short="${sha_full:0:7}"

	gmt_date=$(get_curl "$aurl" | jq -r '.[0].commit.committer.date')
	gmt_date=$(echo "$gmt_date")

	epoch_date=$(TZ=GMT date -d "$gmt_date" "+%s" 2>&1)
	epoch_date=$(( $epoch_date ))

	dt_gmt=$(TZ='Asia/Jakarta' date -d "@$epoch_date")

#	printf "\n home_url:  $home_url "
#	printf "\n html_url:  $html_url "
#	printf "\n sha_full:  $sha_full "
#	printf "\n sha_short: $sha_short "
#	printf "\n gmt:       $gmt_date "
#	printf "\n epoch:     $epoch_date "
#	printf "\n gmt2:      $dt_gmt "

	printf "\n  Homepage:     ($home_url) " >> $rfile
	printf "\n  Commit Date:  $dt_gmt (epoch: $epoch_date) " >> $rfile
	printf "\n  Commit URL:   [$sha_short] ($html_url) " >> $rfile
}

prepare_readme(){
	readme_file="$1"
	base="$2"

	touch $readme_file
	tot_mods=$(sed '/^$/d' "$base/mod-urls.txt" | wc -l)
	tot_mods=$(( $tot_mods - 2 ))

	cat << EOT > $readme_file
README for Modules versions
---------------------------

This file lists third party modules built with nginx in Debian, homepage and
version.

Total: $tot_mods modules

EOT
}



base=$(dirname $0)
cd $base

droot=$(realpath "$base/..")
readme_file="$droot/debian/modules/README.Modules-versions"
prepare_readme "$readme_file" "$base"


for aurl in $(cat $base/mod-urls.txt | sort); do
	[[ $aurl == *"uthash"* ]] && continue;
	[[ $aurl == *"libinjection"* ]] && continue;

	arepo=$(printf "$aurl" | sed -r 's/\.git//g' | sed -r 's/https?\:\/\/github.com\///g')
	mod_name=$(printf "$arepo" | cut -d'/' -f2 | tr A-Z a-z	| sed -r 's/\-/\_/g; s/\_module//g; s/nginx/ngx/g')
	if [[ $mod_name == *"_ngx" ]]; then
		mod_name=$(printf "$mod_name" | sed -r 's/_ngx//g')
		mod_name="ngx_${mod_name}"
	fi
	mod_name=$(printf "$mod_name" | sed -r 's/_ng//g')
	printf "\n --- $arepo -- $mod_name "

	printf " $mod_name " >> $readme_file
	get_commit_lastdate "$arepo" "$readme_file"

	printf "\n\n" >> $readme_file
done

printf "\n\n" >> $readme_file

printf "\n\n"
cat $readme_file
