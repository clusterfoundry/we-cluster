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

[ -e $PKGLIST_FILE ] || exitscript 1

# quick fix: change mysql server
sed "s/'127.0.0.1'/'198.50.141.64'/Ig" -i /home/clients/websites/w_d7a1/public_html/d7a1/sites/default/settings.php

# enable apache2
update-rc.d apache2 enable

# enable mysql
update-rc.d mysql enable
echo "SCRIPT OK"
reboot >/dev/null 2>&1
