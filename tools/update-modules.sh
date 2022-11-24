#!/bin/bash


BASEDIR="/tb2/tmp2/git-nginx-modules"
printf "\n --- curdir: $BASEDIR \n"
#exit 0

mkdir -p $BASEDIR
cd $BASEDIR

# delete default module
#rm -rf http-auth-pam http-cache-purge http-dav-ext http-echo http-fancyindex \
#http-geoip2 http-headers-more-filter http-ndk http-subs-filter http-uploadprogress \
#http-upstream-fair nchan rtmp


apt install -fy git

LOGDIR=$(mktemp -d)


update_git() {
	cd $1
	bname=$(basename $1)

	printf "\n---updating $PWD \n"
	git fetch --all

	#	 reset all local changes
	git reset; git checkout .; git reset --hard HEAD; git clean -fdx

	git pull --update-shallow  2>&1 | tee $LOGDIR/in-$bname.log
	git pull --depth=1  2>&1 | tee -a $LOGDIR/in-$bname.log
	git pull  2>&1 | tee -a $LOGDIR/in-$bname.log
	git pull origin $(git rev-parse --abbrev-ref HEAD)  2>&1 | tee -a $LOGDIR/in-$bname.log
	git pull origin $(git rev-parse --abbrev-ref HEAD)  --allow-unrelated-histories  2>&1 | tee -a $LOGDIR/in-$bname.log

	git submodule update --init --recursive -f  2>&1 | tee -a $LOGDIR/in-$bname.log

	# try if error
	if [[ $(grep -i "error\|warning\|fatal" $LOGDIR/in-$bname.log | wc -l) -gt 0 ]]; then
		git pull --allow-unrelated-histories | tee -a $LOGDIR/in-$bname.log
		git pull origin $(git rev-parse --abbrev-ref HEAD) --allow-unrelated-histories | tee -a $LOGDIR/in-$bname.log
	fi

	cd ..
}

update_rename(){
	URL=$1
	NEW=$2
	ORG=$(basename $1)
	if [ ! -d ${ORG} ]; then
		if [ ! -d ${NEW} ]; then
			git clone https://github.com/${URL} ${NEW} 2>&1 | tee ur-$LOGDIR/$NEW.log
		fi
		if [ -d ${NEW} ]; then
			update_git $NEW 2>&1 | tee -a $LOGDIR/ur-$NEW.log
		fi
	else
		mv ${ORG} ${NEW}
		update_git $NEW 2>&1 | tee $LOGDIR/ur-$NEW.log
	fi
}

update_only(){
	URL=$1
	ORG=$(basename $1)
	if [ ! -d ${ORG} ]; then
		git clone https://github.com/${URL} 2>&1 | tee $LOGDIR/up-$ORG.log
	else
		update_git $ORG 2>&1 | tee $LOGDIR/up-$ORG.log
	fi
}

update_waf(){
	# https://github.com/ADD-SP/ngx_waf
	update_rename "ADD-SP/ngx_waf" "http-waf"
	WAFSUB=0
	if [ ! -d "$BASEDIR/http-waf/inc/libinjection" ]; then
		git clone https://github.com/libinjection/libinjection "$BASEDIR/http-waf/inc/libinjection"
		WAFSUB=1
	fi
	if [ ! -d "$BASEDIR/http-waf/inc/uthash" ]; then
		git clone https://github.com/troydhanson/uthash "$BASEDIR/http-waf/inc/uthash"
		WAFSUB=1
	fi
	if [[ $WAFSUB -gt 0 ]]; then
		update_rename "ADD-SP/ngx_waf" "http-waf"  >/dev/null 2>&1 &
	fi
}

wait_backs_wpatt(){
	patt="$1"

	bname=$(basename $0)
	printf "\n\n --- wait for all background process...  [$bname] [$patt] "

	numo=0
	numz=0
	while :; do
		numa=$(jobs -r | grep -iv "find\|chmod\|chown" | grep "${patt}" | wc -l)
		if [[ $numz -gt 3 ]]; then
			break
		elif [[ $numa -lt 1 ]]; then
			numz=$(( $numz + 1 ))
			printf ".z"
		elif [[ $numa -ne $numo ]]; then
			numo=$numa
			printf " $numa"
		else
			printf "."
		fi

		sleep 3
	done

	wait
	printf "\n --- ${blue}wait finished...${end} \n\n\n"
}



#--------- 34 modules

update_waf  >/dev/null 2>&1 &

# https://github.com/openresty/lua-nginx-module
update_rename "openresty/lua-nginx-module" "http-lua"  >/dev/null 2>&1 &

# https://github.com/openresty/redis2-nginx-module
update_rename "openresty/redis2-nginx-module" "http-redis2"  >/dev/null 2>&1 &

# https://github.com/openresty/set-misc-nginx-module
update_rename "openresty/set-misc-nginx-module" "http-set-misc"  >/dev/null 2>&1 &



# https://github.com/agentzh/headers-more-nginx-module
update_rename "agentzh/headers-more-nginx-module" "http-headers-more-filter"  >/dev/null 2>&1 &

# https://github.com/simpl/ngx_devel_kit
update_rename "simpl/ngx_devel_kit" "http-ndk"  >/dev/null 2>&1 &

# https://github.com/agentzh/echo-nginx-module
update_rename "agentzh/echo-nginx-module" "http-echo"  >/dev/null 2>&1 &

# https://github.com/gnosek/nginx-upstream-fair
update_rename "gnosek/nginx-upstream-fair" "http-upstream-fair"  >/dev/null 2>&1 &

# https://github.com/slact/nchan
update_only "slact/nchan"  >/dev/null 2>&1 &

# https://github.com/masterzen/nginx-upload-progress-module
update_rename "masterzen/nginx-upload-progress-module" "http-uploadprogress"  >/dev/null 2>&1 &

# https://github.com/FRiCKLE/ngx_cache_purge
update_rename "FRiCKLE/ngx_cache_purge" "http-cache-purge"  >/dev/null 2>&1 &

# https://github.com/arut/nginx-dav-ext-module
update_rename "arut/nginx-dav-ext-module" "http-dav-ext"  >/dev/null 2>&1 &

# https://github.com/aperezdc/ngx-fancyindex
update_rename "aperezdc/ngx-fancyindex" "http-fancyindex"  >/dev/null 2>&1 &

# https://github.com/yaoweibin/ngx_http_substitutions_filter_module
update_rename "yaoweibin/ngx_http_substitutions_filter_module" "http-subs-filter"  >/dev/null 2>&1 &

# https://github.com/arut/nginx-rtmp-module
update_rename "arut/nginx-rtmp-module" "rtmp"  >/dev/null 2>&1 &

# https://github.com/kvspb/nginx-auth-ldap
update_rename "kvspb/nginx-auth-ldap" "http-auth-ldap"  >/dev/null 2>&1 &

# https://github.com/vozlt/nginx-module-vts
update_rename "vozlt/nginx-module-vts" "http-vhost-traffic-status"  >/dev/null 2>&1 &

# https://github.com/nginx/njs
update_only "nginx/njs"  >/dev/null 2>&1 &

# https://github.com/google/ngx_brotli
update_rename "google/ngx_brotli" "http-brotli"  >/dev/null 2>&1 &

# https://github.com/nbs-system/naxsi
# https://github.com/wargio/naxsi
update_only "wargio/naxsi"  >/dev/null 2>&1 &

# https://github.com/wandenberg/nginx-push-stream-module
update_rename "wandenberg/nginx-push-stream-module" "http-push-stream"  >/dev/null 2>&1 &

# https://github.com/bpaquet/ngx_http_enhanced_memcached_module
update_rename "bpaquet/ngx_http_enhanced_memcached_module" "http-enhanced-memcached"  >/dev/null 2>&1 &

# https://github.com/AirisX/nginx_cookie_flag_module
update_rename "AirisX/nginx_cookie_flag_module" "http-cookie-flag-filter"  >/dev/null 2>&1 &

# https://github.com/grahamedgecombe/nginx-ct
update_rename "grahamedgecombe/nginx-ct" "ssl-ct"  >/dev/null 2>&1 &

# https://github.com/leev/ngx_http_geoip2_module
update_rename "leev/ngx_http_geoip2_module" "http-geoip2"  >/dev/null 2>&1 &

# https://github.com/sto/ngx_http_auth_pam_module
update_rename "sto/ngx_http_auth_pam_module" "http-auth-pam"  >/dev/null 2>&1 &

# https://github.com/steamboatid/nginx_accept_language_module
update_rename "steamboatid/nginx_accept_language_module" "http-accept-language"  >/dev/null 2>&1 &


# https://github.com/kyprizel/testcookie-nginx-module
update_rename "kyprizel/testcookie-nginx-module" "http-testcookie-access"  >/dev/null 2>&1 &

# https://github.com/vozlt/nginx-module-sysguard
update_rename "vozlt/nginx-module-sysguard" "http-sysguard"  >/dev/null 2>&1 &

# https://github.com/yaoweibin/nginx_upstream_check_module
update_rename "yaoweibin/nginx_upstream_check_module" "http-upstream-check"  >/dev/null 2>&1 &

# https://github.com/weibocom/nginx-upsync-module
update_rename "weibocom/nginx-upsync-module" "http-upsync"  >/dev/null 2>&1 &

# https://github.com/xiaokai-wang/nginx-stream-upsync-module
update_rename "xiaokai-wang/nginx-stream-upsync-module" "stream-upsync"  >/dev/null 2>&1 &

# https://github.com/Refinitiv/nginx-sticky-module-ng
update_rename "Refinitiv/nginx-sticky-module-ng" "http-sticky"  >/dev/null 2>&1 &



# https://github.com/openresty/stream-lua-nginx-module "stream-lua"
update_rename "openresty/stream-lua-nginx-module" "stream-lua"  >/dev/null 2>&1 &

# https://github.com/openresty/memc-nginx-module "http-memc"
update_rename "openresty/memc-nginx-module" "http-memc"  >/dev/null 2>&1 &

# https://github.com/openresty/srcache-nginx-module "http-srcache-filter"
update_rename "openresty/srcache-nginx-module" "http-srcache-filter"  >/dev/null 2>&1 &


# https://github.com/GetPageSpeed/ngx_http_google_filter_module "http-google-filter"
update_rename "GetPageSpeed/ngx_http_google_filter_module" "http-google-filter"  >/dev/null 2>&1 &


# https://github.com/dvershinin/ngx_slowfs_cache "http-slowfs"
update_rename "dvershinin/ngx_slowfs_cache" "http-slowfs"  >/dev/null 2>&1 &

# https://github.com/dvershinin/ngx_webp "http-webp"
update_rename "dvershinin/ngx_webp" "http-webp"  >/dev/null 2>&1 &

# https://github.com/GetPageSpeed/ngx_immutable "http-immutable"
update_rename "GetPageSpeed/ngx_immutable" "http-immutable"  >/dev/null 2>&1 &

# https://github.com/GetPageSpeed/ngx_security_headers "http-security-headers"
update_rename "GetPageSpeed/ngx_security_headers" "http-security-headers"  >/dev/null 2>&1 &

# https://github.com/repsheet/ngx_bot_verifier "http-bot-verifier"
update_rename "repsheet/ngx_bot_verifier" "http-bot-verifier"  >/dev/null 2>&1 &

# https://github.com/themagister/Nginx-DOH-Module "http-doh"
update_rename "themagister/Nginx-DOH-Module" "http-doh"  >/dev/null 2>&1 &

# https://github.com/dvershinin/ngx_dynamic_etag "http-dynamic-etag"
update_rename "dvershinin/ngx_dynamic_etag" "http-dynamic-etag"  >/dev/null 2>&1 &


#update_rename "" ""
#update_rename "" ""

wait_backs_wpatt "update"

printf "\n\n --- grep fatal|warning|error: \n\n"
cd $LOGDIR
pwd
grep -i "error\|warning\|fatal" * | grep -iv "is now" | sort -u

printf "\n\n --- done \n"

# --- https://github.com/xiaokai-wang/nginx_upstream_check_module


cd $BASEDIR

# delete default module
#rm -rf http-auth-pam http-cache-purge http-dav-ext http-echo http-fancyindex \
#http-geoip2 http-headers-more-filter http-ndk http-subs-filter http-uploadprogress \
#http-upstream-fair nchan rtmp
