#!/bin/bash


adir=$(dirname $0)
adir=$(realpath $adir/..)
cd $adir

/bin/bash tools/clean.sh

lxc-start -qn teye
lxc-start -qn eye
lxca eye -- sh -c "cd /root/src/nginx/git-nginx/tools; bash ./clean.sh"

rsync -aHAXvztr --numeric-ids --modify-window 5 --omit-dir-times --delete \
--exclude ".git" \
/tb2/root/github/nginx/* /var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/

rsync -aHAXvztr --numeric-ids --modify-window 5 --omit-dir-times --delete \
--exclude ".git" \
/tb2/root/github/nginx/* /var/lib/lxc/eye/rootfs/root/org.src/nginx/git-nginx/

#lxca eye -- sh -c "cd /root/src/nginx/git-nginx/tools/; bash ./zbuild.sh"
find /var/lib/lxc/eye/rootfs/root/src/nginx/ -maxdepth 2 -type f -iname "*.deb" -delete
#lxca eye -- /tb2/build-devomd/dk-build-full.sh -d /root/src/nginx/git-nginx
lxca eye -- /tb2/build-devomd/dk-build-nginx.sh


find /var/lib/lxc/eye/rootfs/root/src/nginx/ -maxdepth 2 -type f -iname "*dev*" -delete
rm -rf /var/lib/lxc/teye/rootfs/tmp/debs; \
mkdir -p /var/lib/lxc/teye/rootfs/tmp/debs; \
cp -fav /var/lib/lxc/eye/rootfs/root/src/nginx/*deb /var/lib/lxc/teye/rootfs/tmp/debs

lxca teye -- sh -c "\
dpkg --configure -a; apt install -fy; \
rm -rf /etc/nginx /etc/php; \
cd /tmp; apt purge --auto-remove --purge -fy nginx* php*; \
rm -rf /etc/nginx /etc/php; \
apt install -fy \
bison flex fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libfreetype6 libgd3 libgeoip1 libgoogle-perftools4 libhiredis0.14 \
libjbig0 libjpeg62-turbo libpng16-16 libsigsegv2 libsodium23 libtcmalloc-minimal4 libtiff5 libunwind8 libwebp6 libxpm4 libxslt1.1 m4; \
cd /tmp/debs; rm -rf *dev*; dpkg --force-all -i ./nginx-extras*.deb ./nginx-common*.deb ./libnginx-mod-*deb; \
find /etc/nginx/modules-enabled -iname "*google*"; \
nginx -t"
