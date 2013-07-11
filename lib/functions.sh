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
		SSH)
			echo "$SSH_CLUSTER_MEMBERS" \
			| sed 's/|/\n/g'
		;;
		*)
			echo "SCRIPT ERR"
			return 2
		;;
	esac
}

function getNodePassword() {
	# Param: getNodePassword <WEB|MYSQL|STORAGE> <ip address>
	[ $1 -a $2 ] || return 2
	return 0
}

function msg() {
	echo "+ $*:"
}

function exitmsg() {
	exitcode=$1; shift
	echo "+ ERROR: $*"
	exit $exitcode
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

function getDPApps() {
	dp_user=`cat "$DEVPANEL_APPS_FILE" | sed 's/#.*//g' | sed '/^\s*$/d'`
	if [ x"$dp_user" == x"" ]; then
		return 1
	else
		echo -n "$dp_user"
	fi
	exit 0
}

function dumpVars() {
	for var in $*; do
		eval "echo $var=\\\"\"\$$var\"\\\""
	done
}

function getDP_rootPass() {
	dp_user=$1
	dp_pass=`cat "$DEVPANEL_PASSWD_FILE" | egrep "^${dp_user}:" | awk -F: '{print $9}'`
	if [ x"$dp_pass" == x"" ]; then
		return 1
	else
		echo -n "$dp_pass"
	fi
	exit 0
}
