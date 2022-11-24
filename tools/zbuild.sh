#!/bin/bash

adir=$(dirname $(dirname $0))
cd $adir
pwd

#-- refresh readme
nohup /bin/bash $adir/tools/refresh-readme-mods.sh >/dev/null 2>&1 &

#fakeroot debian/rules clean
#rm -rf objs

export LUAJIT_INC=/usr/include/luajit-2.1
export LUAJIT_LIB=/usr/lib/x86_64-linux-gnu/

LDLUA=`pcre2-config --libs8`
#export LDFLAGS="$LDFLAGS $LDLUA"
export LDFLAGS="$LDFLAGS -lpcre"
export CFLAGS="$CFLAGS $LDLUA -O3"

./configure \
--prefix=/usr/share/nginx \
--conf-path=/etc/nginx/nginx.conf \
--http-log-path=/var/log/nginx/access.log \
--error-log-path=/var/log/nginx/error.log \
--lock-path=/var/lock/nginx.lock \
--pid-path=/run/nginx.pid \
--modules-path=/usr/lib/nginx/modules \
--http-client-body-temp-path=/var/lib/nginx/body \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-scgi-temp-path=/var/lib/nginx/scgi \
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
--with-compat \
--with-debug \
--with-pcre \
--with-pcre-jit \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_auth_request_module \
--with-http_v2_module \
--with-http_dav_module \
--with-http_slice_module \
--with-threads \
--with-http_gzip_static_module \
--with-http_addition_module \
--with-http_geoip_module \
--with-http_gunzip_module \
--with-http_image_filter_module \
--with-http_sub_module \
--with-http_xslt_module \
--with-stream \
--with-stream_ssl_module \
--with-mail \
--with-mail_ssl_module \
--with-stream_ssl_preread_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_perl_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--add-module=debian/modules/http-ndk \
--add-module=debian/modules/http-subs-filter \
\
--add-module=debian/modules/http-memc \
--add-module=debian/modules/http-srcache-filter \
--add-module=debian/modules/http-google-filter \
--add-module=debian/modules/http-slowfs \
--add-module=debian/modules/http-webp \
--add-module=debian/modules/http-immutable \
--add-module=debian/modules/http-security-headers \
--add-module=debian/modules/http-bot-verifier \
--add-module=debian/modules/http-doh \
\
--add-module=debian/modules/http-accept-language \
--add-module=debian/modules/http-auth-ldap \
--add-module=debian/modules/http-auth-pam \
--add-module=debian/modules/http-brotli \
--add-module=debian/modules/http-cache-purge \
--add-module=debian/modules/http-dav-ext \
--add-module=debian/modules/http-echo \
--add-module=debian/modules/http-fancyindex \
--add-module=debian/modules/http-headers-more-filter \
--add-module=debian/modules/http-redis2 \
--add-module=debian/modules/http-set-misc \
--add-module=debian/modules/http-upstream-fair \
--add-module=debian/modules/http-vhost-traffic-status \
--add-module=debian/modules/nchan \
--add-module=debian/modules/rtmp \
\
--add-module=debian/modules/http-cookie-flag-filter \
--add-module=debian/modules/http-enhanced-memcached \
--add-module=debian/modules/http-push-stream \
--add-module=debian/modules/http-sysguard \
--add-module=debian/modules/http-testcookie-access \
--add-module=debian/modules/http-upstream-check \
\
--add-module=debian/modules/http-upsync \
--add-module=debian/modules/stream-upsync \
--add-module=debian/modules/http-geoip2 \
--add-module=debian/modules/ssl-ct \
--add-module=debian/modules/njs/nginx \
--add-module=debian/modules/http-sticky \
\
--add-module=debian/modules/naxsi/naxsi_src \
--add-module=debian/modules/http-dynamic-etag \


# lua only compatible w/ PCRE v1
# --add-module=debian/_baks/baks/modules/http-lua \
# --add-module=debian/modules/http-lua \
# --add-module=debian/modules/stream-lua \

#--add-dynamic-module=debian/modules/http-waf \
#--add-module=debian/modules/http-uploadprogress \



rm -rf objs/nginx

make -j8 modules 2>&1 | tee dkzbuild.log
make -j8 | tee dkzbuild.log

[[ -e objs/nginx ]] && objs/nginx -V
[[ -e objs/nginx ]] && objs/nginx -V 2>&1 | grep --color sticky

/bin/bash $adir/tools/check-zbuild.sh
