#!/bin/bash -u

CLUSTER_CONFIG_FILE=/opt/webenabled/cluster/etc/cluster.conf
SCRIPT_LIBRARY=/opt/webenabled/cluster/lib/functions.sh
SCRIPT_ABSPATH=`readlink -f $0`
SCRIPT_DIR=`dirname "$SCRIPT_ABSPATH"`
SCRIPT_NAME=`basename $0`

# apt-get update
# install sshpass
# apt-get update
# dpkg --get-selections > $pkglist
# dpkg --set-selections < $pkglist
# /etc/rc*
# /etc/init
# /etc/init.d/

# load functions
source $SCRIPT_LIBRARY || exit 2
# load configurations
source "$CLUSTER_CONFIG_FILE" || exit 2

# create temporary file
TMPFILE=`mktemp /tmp/pkg.XXXXXX` || exit 1

# get installed packages and save to temp file
dpkg --get-selections > $TMPFILE || exit 1

# copy
# SSHPASS="1P@ssw0rd9" sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@198.50.239.48 "cat -"

CLUSTER_MEMBERS=198.50.239.49
for host in CLUSTER_MEMBERS; do
	node_ip=198.50.239.49
	node_pass='1P@ssw0rd9'
	node_cmd='cat - > /tmp/pkglist'
	errmsg debug "Sending package list to $node_ip"

	# transfer package list
	cat $TMPFILE | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - | tee /tmp/pkglist" | sed 's/^/EXEC['$node_ip'] >> /g'

	# execute script to transfer packagelist
	cat "${SCRIPT_DIR}/sync_pkg.sh" | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - > /tmp/sync_pkg.sh; chmod +x /tmp/sync_pkg.sh; /tmp/sync_pkg.sh /tmp/pkglist" | sed 's/^/EXEC['$node_ip'] >> /g'
done
