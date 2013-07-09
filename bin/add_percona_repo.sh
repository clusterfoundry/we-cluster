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

# add percona apt key
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A || exitscript 1

# add percona repository
source /etc/lsb-release || exitscript 1
[ $DISTRIB_CODENAME ] || exitscript 1

echo "deb http://repo.percona.com/apt $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt $DISTRIB_CODENAME main" >> /etc/apt/sources.list.d/percona.list

echo "SCRIPT OK"
