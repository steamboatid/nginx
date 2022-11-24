#!/bin/bash


rootdir=$(dirname $0)
rootdir=$(realpath $rootdir/..)
cd $rootdir


exec_devomd(){
	printf "\n $1 -- $2 "
	acomm="cd $rootdir; /usr/bin/lxc-attach -e -R --keep-env --name=$1 -- bash -lc '$2'"
	printf "\n -- $acomm\n"
	ssh devomd -- bash -lc "$acomm"
}
exec_devomd "eye" "mkdir -p $rootdir"

prep_local(){
	/bin/bash tools/clean.sh

	ssh devomd -- lxc-start -qn teye
	ssh devomd -- lxc-start -qn eye
	exec_devomd "eye" "/bin/bash /root/src/nginx/git-nginx/tools/clean.sh"
	exec_devomd "eye" "mkdir -p /var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/"
	exec_devomd "eye" "mkdir -p /var/lib/lxc/eye/rootfs/root/org.src/nginx/git-nginx/"
}

sync_devomd(){
#	rsync -aHAXvztr --numeric-ids --modify-window 5 --omit-dir-times \
	rsync -aHAXvztr --numeric-ids \
	--delete \
	--info=flist --info=skip0 \
	--exclude ".git" \
	-e "ssh -p22022 -T -o Compression=no -x"  \
	/tb2/root/github/nginx/* devomd:/var/lib/lxc/eye/rootfs/root/org.src/nginx/git-nginx/

	exec_devomd "eye" "find /var/lib/lxc/eye/rootfs/root/org.src/nginx/ -maxdepth 2 -type f -iname \"*.deb\" -delete"
	exec_devomd "eye" "rsync -aHAXztr -delete /root/org.src/nginx/git-nginx/* /root/src/nginx/git-nginx/"
	exec_devomd "eye" "find /var/lib/lxc/eye/rootfs/root/src/nginx/ -maxdepth 2 -type f -iname \"*.deb\" -delete"
}


prep_local
sync_devomd

exec_devomd "eye" "/bin/bash /root/src/nginx/git-nginx/tools/zbuild.sh"
#exit 0;

exec_devomd "eye" "/bin/bash /tb2/build-devomd/dk-build-nginx.sh"
exec_devomd "eye" "find /var/lib/lxc/eye/rootfs/root/src/nginx/ -maxdepth 2 -type f -iname \"*dev*\" -delete"
#exit 0;

ssh devomd -- bash -lc "rm -rf /var/lib/lxc/teye/rootfs/tmp/debs; \
mkdir -p /var/lib/lxc/teye/rootfs/tmp/debs; \
cp -fav /var/lib/lxc/eye/rootfs/root/src/nginx/*deb /var/lib/lxc/teye/rootfs/tmp/debs"

exec_devomd "teye" "\
dpkg --configure -a; \
DEBIAN_FRONTEND=\"noninteractive\" apt install -fy; \
rm -rf /etc/nginx /etc/php; \
cd /tmp; apt purge -fy nginx*; \
rm -rf /etc/nginx; \
DEBIAN_FRONTEND=\"noninteractive\" apt install -fy \
dialog apt-utils \
bison flex fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libfreetype6 libgd3 libgeoip1 libgoogle-perftools4 libhiredis0.14 \
libjbig0 libjpeg62-turbo libpng16-16 libsigsegv2 libsodium23 libtcmalloc-minimal4 libtiff5 libunwind8 libwebp6 libxpm4 libxslt1.1 m4; \
cd /tmp/debs; rm -rf *dev*; dpkg --force-all -i ./nginx-extras*.deb ./nginx-common*.deb ./libnginx-mod-*deb; \
find /etc/nginx/modules-enabled -iname \"*google*\"; \
nginx -t"
