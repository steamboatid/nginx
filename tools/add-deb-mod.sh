#!/bin/bash


# create debian/libnginx-mod-{module_name}.nginx
create_file_dot_nginx(){
	mname="$1"
	adir="$2"

	odir=$PWD
	mkdir -p $adir/debian
	cd $adir/debian

	fname="$adir/debian/libnginx-mod-${mname}.nginx"

	cat << \EOT > "$fname"
#!/usr/bin/perl -w

use File::Basename;

# Guess module name
$module = basename($0, '.nginx');
$module =~ s/^libnginx-mod-//;

$modulepath = $module;
$modulepath =~ s/-/_/g;

print "mod debian/build-extras/objs/ngx_${modulepath}_module.so\n";
print "mod debian/libnginx-mod.conf/mod-${module}.conf\n";
EOT

	printf "\n\n --- $fname \n"; cat "$fname"

	chmod +x "$fname"
	cd "$odir"
}


# create debian/libnginx-mod.conf/mod-{module_name}.conf
create_file_dot_conf(){
	mname="$1"
	adir="$2"

	odir=$PWD
	mkdir -p $adir/debian/libnginx-mod.conf
	cd $adir/debian/libnginx-mod.conf

	uname=$(printf "$mname" | sed -r 's/\_/\-/g')
	fname="$adir/debian/libnginx-mod.conf/mod-${uname}.conf"

	modname=$(printf "$uname" | sed -r 's/\-/\_/g')
	echo "load_module modules/ngx_${modname}_module.so;" > "$fname"

	printf "\n\n --- $fname \n"; cat "$fname"
	cd "$odir"
}



# args:
#-------------------------------------------
# -m <module_name>
# -d <directory_name>
#-------------------------------------------

# while getopts d:y:a: flag
while getopts d:m: flag
do
	case "${flag}" in
		d) dir=${OPTARG};;
		m) mod=${OPTARG};;
	esac
done

if [[ -z "${dir}" ]] || [[ -z "${mod}" ]]; then
	printf "\n Usage: $0 -d <directory> -m <module_name> \n\n"
	exit 1
fi

if [[ ! -d "${dir}" ]]; then
	printf "\n --- ${dir} is not a directory \n\n"
	exit 1
fi

cdir=$(realpath $dir)
droot=$(realpath "$cdir/..")
cd $droot

create_file_dot_nginx "$mod" "$droot"
create_file_dot_conf "$mod" "$droot"

printf "\n\n --done \n"
