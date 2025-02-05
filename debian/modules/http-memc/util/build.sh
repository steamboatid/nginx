#!/bin/bash

# this file is mostly meant to be used by the author himself.

ragel -I src -T1 src/ngx_http_memc_response.rl || exit 1
util/fix-clang-warnings

if [ $? != 0 ]; then
    echo 'Failed to generate the memcached response parser.' 1>&2
    exit 1;
fi

root=`pwd`
version=$1
home=~
force=$2

ngx-build $force $version \
    --with-ld-opt="-L$PCRE_LIB -Wl,-rpath,$PCRE_LIB:$LIBDRIZZLE_LIB:/usr/local/lib" \
    --with-cc-opt="-O3" \
    --with-http_addition_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-http_upstream_ip_hash_module \
    --without-http_empty_gif_module \
    --without-http_referer_module \
    --without-http_autoindex_module \
    --without-http_auth_basic_module \
    --without-http_userid_module \
    --add-module=$root $opts \
    --add-module=$root/../ndk-nginx-module \
    --add-module=$root/../eval-nginx-module \
    --add-module=$root/../echo-nginx-module \
    --add-module=$root/../set-misc-nginx-module \
    --add-module=$root/../lua-nginx-module \
          --with-select_module \
          --with-poll_module \
    --with-debug
    #--add-module=$home/work/nginx/nginx_upstream_hash-0.3 \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)

