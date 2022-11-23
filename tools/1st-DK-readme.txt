
TOC :
a. how to add dynamic modules
b. change module symlink priority
c. update/add existing modules
d. patching main nginx src
e. upgrading / bug fixing main repo



A. HOW TO ADD DYNAMIC MODULES:
- put source at debian/modules
- get {module_name} from debian/modules/{module_folder}/source/config
- create debian/libnginx-mod-{module_name}.nginx
- chmod +x debian/libnginx-mod-{module_name}.nginx
- create debian/libnginx-mod.conf/mod-{module_name}.conf
- add config debian/control
- add config debian/rules

B. CHANGE MODULE SYMLINK PRIORITY
- edit file debian/libnginx-mod-{module_name}.nginx
- at example, priority 59
example:
print "mod debian/libnginx-mod.conf/mod-${module}.conf 59 \n";




C. UPDATE/ADD EXISTING MODULES:
C1. change build options
---------------------------------------------------------
- execute at host:
	cd /tb2/root/github/nginx; /bin/bash tools/update-modules.sh

- vscode /tb2/tmp2/git-nginx-modules/
	replace "-O2" with "-O3"

C2. merge to lxc
---------------------------------------------------------
	domeld /tb2/root/github/nginx /tb2/tmp2/git-nginx-modules
	domeld /tb2/tmp2/git-nginx-modules /tb2/root/github/nginx/debian/modules
	domeld /var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/debian/modules /tb2/tmp2/git-nginx-modules

rsync -aHAXvztrn --numeric-ids --ignore-existing \
--exclude 'config' --exclude '.git' \
/tb2/tmp2/git-nginx-modules/ \
/var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/debian/modules/

rsync -aHAXvztrn --numeric-ids \
--exclude 'config' --exclude '*.c' --exclude '*.h' --exclude '.git' \
/tb2/tmp2/git-nginx-modules/ \
/var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/debian/modules/

rsync -aHAXvztrn --numeric-ids --ignore-existing \
--exclude '.git' \
/tb2/tmp2/git-nginx-modules/ \
/var/lib/lxc/wor/rootfs/root/src/nginx/git-nginx/debian/modules/


C3. TEST BUILD at src/nginx {lxc eye}
---------------------------------------------------------
	vscode /var/lib/lxc/eye/rootfs/root/src/nginx/git-nginx/tools/zbuild.sh
	lxca eye -- /bin/bash /root/src/nginx/git-nginx/tools/zbuild.sh


C4. Prepare Debian packaging
---------------------------------------------------------
- see 1st-DK-readme.txt
- execute add-deb-mod.sh at lxc
	lxcr eye
	cd ~/src/nginx/git-nginx
	/bin/bash tools/add-deb-mod.sh -d ~/src/nginx/git-nginx -m "{module_name}"

- modify debian/rules
- modify debian/control

- clean .git directory at debian/modules
	find debian/modules -type d -iname ".git" -exec rm -rv {} \;


C5. Execute Debian packaging (at host, DIRECT)
---------------------------------------------------------
	lxca eye -- /bin/bash /tb2/build/dk-build-full.sh -d /root/src/nginx/git-nginx


C6. MERGING: src/nginx to org.src/nginx {at HOST}
---------------------------------------------------------
	cd /var/lib/lxc/eye/rootfs/root
	domeld org.src/nginx/git-nginx src/nginx/git-nginx


C7. MERGING back to MAIN REPO
---------------------------------------------------------
	domeld ~/github/nginx /var/lib/lxc/eye/rootfs/root/org.src/nginx/git-nginx



D. PATCHING main nginx src
---------------------------------------------------------
- patching is needed if the source is brand new
- PATCHING: after domeld (at lxc eye)

	lxc-run eye
	cd src/nginx/git-nginx; patch -p1 < debian/modules/http-upstream-check/check_1.20.1+.patch;
	cd ~/src/nginx/git-nginx/debian/modules/http-upstream-fair; patch < ../http-upstream-check/upstream_fair.patch

- goto C3 above



E. UPGRADING / BUG FIXING main repo
---------------------------------------------------------

E1. AT HOST
---------------------------------------------------------
rm -rf /tmp/aa/nginx; \
mkdir -p /tmp/aa; cd /tmp/aa; \
git clone git@github.com:nginx/nginx.git; \
atag=$(git tag --sort=-version:refname | head -n1); git checkout $atag
domeld /tmp/aa/nginx ~/github/nginx


E2. do some changes of ~/github/nginx

E3. make sure this vars/consts NOT missing:
---------------------------------------------------------
NGX_UPSTREAM_CHECK_MODULE
NGX_HTTP_UPSTREAM_CHECK
//dkmods

E4. execute at host :
---------------------------------------------------------
cd ~/github/nginx; /bin/bash tools/zbuild.sh
cd ~/github/nginx; /bin/bash tools/loc-build.sh
