#!/bin/bash
PKGLIST_FILE="$1"
DEBIAN_FRONTEND=noninteractive

function exitscript() {
	if [ $1 -eq 0 ]; then
		echo "SCRIPT OK"
		exit 0
	else
		echo "SCRIPT ERROR $1"
		exit $1
	fi
}

# disable apache
echo "Disabling apache2"
update-rc.d apache2 disable

# disable mysql
echo "Disabling MySQL"
update-rc.d mysql disable
mv /etc/init/mysql.conf /etc/init/mysql.conf.disabled



# disable taskd and dbmgr if there's any
echo "Disabling devPanel taskd and dbmgr"
mv /etc/init/taskd.conf /etc/init/taskd.conf.disabled
mv /etc/init/dbmgr.conf /etc/init/dbmgr.conf.disabled

echo "SCRIPT OK"
reboot >/dev/null 2>&1
