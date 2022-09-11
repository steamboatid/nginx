#!/bin/bash

adir=$(dirname $(dirname $0))
cd $adir
pwd

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
--add-dynamic-module=debian/modules/http-ndk \
\
--add-dynamic-module=debian/modules/http-sticky \
--add-dynamic-module=debian/modules/http-subs-filter \
--add-dynamic-module=debian/modules/http-google-filter \
--add-dynamic-module=debian/modules/http-vhost-traffic-status \
--add-dynamic-module=debian/modules/naxsi/naxsi_src \
\
--add-dynamic-module=debian/modules/http-auth-pam \
--add-dynamic-module=debian/modules/http-cache-purge \
--add-dynamic-module=debian/modules/http-dav-ext \
--add-dynamic-module=debian/modules/http-echo \
--add-dynamic-module=debian/modules/http-fancyindex \
--add-dynamic-module=debian/modules/http-geoip2 \
--add-dynamic-module=debian/modules/http-headers-more-filter \
--add-dynamic-module=debian/modules/http-uploadprogress \
--add-dynamic-module=debian/modules/http-upstream-fair \
--add-dynamic-module=debian/modules/nchan \
--add-dynamic-module=debian/modules/rtmp \
\
--add-dynamic-module=debian/modules/http-accept-language \
--add-dynamic-module=debian/modules/http-auth-ldap \
--add-dynamic-module=debian/modules/http-bot-verifier \
--add-dynamic-module=debian/modules/http-brotli \
--add-dynamic-module=debian/modules/http-cookie-flag-filter \
--add-dynamic-module=debian/modules/http-doh \
--add-dynamic-module=debian/modules/http-enhanced-memcached \
--add-dynamic-module=debian/modules/http-immutable \
--add-dynamic-module=debian/modules/http-memc \
--add-dynamic-module=debian/modules/http-push-stream \
--add-dynamic-module=debian/modules/http-redis2 \
--add-dynamic-module=debian/modules/http-security-headers \
--add-dynamic-module=debian/modules/http-set-misc \
--add-dynamic-module=debian/modules/http-slowfs \
--add-dynamic-module=debian/modules/http-srcache-filter \
--add-dynamic-module=debian/modules/http-sysguard \
--add-dynamic-module=debian/modules/http-testcookie-access \
--add-dynamic-module=debian/modules/http-upstream-check \
--add-dynamic-module=debian/modules/http-waf \
--add-dynamic-module=debian/modules/http-webp \
--add-dynamic-module=debian/modules/ssl-ct \



#--add-dynamic-module=debian/modules/http-upsync \
#--add-dynamic-module=debian/modules/stream-upsync \
#--add-dynamic-module=debian/modules/njs/nginx \

# lua only compatible w/ PCRE v1
# --add-dynamic-module=debian/_baks/baks/modules/http-lua \
# --add-dynamic-module=debian/modules/stream-lua \



rm -rf objs/nginx

make -j8 | tee dkzbuild.log
[[ -e objs/nginx ]] && objs/nginx -V
#[[ -e objs/nginx ]] && objs/nginx -V 2>&1 | grep --color sticky
