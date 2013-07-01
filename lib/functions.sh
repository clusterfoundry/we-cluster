#!/bin/bash -u

function getNodeInfo() {
	[ $1 ] || exit 2
	case $1 in
		WEB)
			echo "$WEB_CLUSTER_MEMBERS" \
			| sed 's/|/\n/g'
		;;
		MYSQL)
			echo "$MYSQL_CLUSTER_MEMBERS" \
			| sed 's/|/\n/g'
		;;
		STORAGE)
			echo "$STORAGE_CLUSTER_MEMBERS" \
			| sed 's/|/\n/g'
		;;
		*)
			echo "SCRIPT ERR"
			exit 2
		;;
	esac
}

function getNodePassword() {
	# Param: getNodePassword <WEB|MYSQL|STORAGE> <ip address>
	[ $1 -a $2 ] || exit 2
}

function msg() {
	echo "$*" | logger -t local0.info -s
}

function check_bin() {
	for bin in $*; do
		echo -n "checking for $bin..."
		path=`which "$bin"`
		if [ $? -ne 0 ]; then
			echo NONE
			return 0
		fi
		echo $path
	done
}
