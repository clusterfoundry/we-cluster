#!/bin/bash -u

CLUSTER_HOME=/opt/webenabled/cluster
CLUSTER_CONFIG_FILE=$CLUSTER_HOME/etc/cluster.conf
SCRIPT_LIBRARY=$CLUSTER_HOME/lib/functions.sh
SCRIPT_ABSPATH=`readlink -f $0`
SCRIPT_DIR=`dirname "$SCRIPT_ABSPATH"`
SCRIPT_NAME=`basename $0`

# load configurations
source "$CLUSTER_CONFIG_FILE" || exit 2
# load functions
source $SCRIPT_LIBRARY || exit 2

# apt-get update
# install sshpass
# apt-get update
# dpkg --get-selections > $pkglist
# dpkg --set-selections < $pkglist
# /etc/rc*
# /etc/init
# /etc/init.d/

# install sshpass
apt-get install -y sshpass || exitmsg 1 "Unable to install sshpass"

# create temporary file
TMPFILE=`mktemp /tmp/pkg.XXXXXX` || exitmsg 1 "Unable to create temporary file"

# get installed packages and save to temp file
dpkg --get-selections > $TMPFILE || exitmsg 1 "Cannot retrieve list of packages"

# copy
# SSHPASS="1P@ssw0rd9" sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@198.50.239.48 "cat -"

ssh_node=`getNodeInfo SSH | awk -F: '{print $1}'`
for node_ip in $ssh_node; do
        # if node_ip matches to any assigned ip to local interface, then skup
	if ( ip addr show | grep -q ${node_ip}/ ); then
		msg "$SCRIPT_NAME: IP ${node_ip} matches local IP. Skipping..."
		continue
	fi

	node_pass='1P@ssw0rd9'
	node_cmd='cat - > /tmp/pkglist'

	msg "Sending package list to $node_ip"

	# add percona repository
	msg "$SCRIPT_NAME: Add Percona APT Repository"
	cat "${SCRIPT_DIR}/add_percona_repo.sh" | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - > /tmp/add_percona_repo.sh; chmod +x /tmp/add_percona_repo.sh; /tmp/add_percona_repo.sh" | sed 's/^/['$node_ip'] >> /g'

	# transfer package list
	msg "$SCRIPT_NAME: Transfer package list to ${node_ip}"
	cat $TMPFILE | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - | tee /tmp/pkglist" | sed 's/^/EXEC['$node_ip'] >> /g'

	# execute script to transfer packagelist
	msg "$SCRIPT_NAME: Install packages on ${node_ip}"
	cat "${SCRIPT_DIR}/sync_pkg.sh" | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - > /tmp/sync_pkg.sh; chmod +x /tmp/sync_pkg.sh; /tmp/sync_pkg.sh /tmp/pkglist" | sed 's/^/['$node_ip'] >> /g'
done

$CLUSTER_HOME/bin/41-disable_remote_services.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/41-disable_remote_services.sh"
$CLUSTER_HOME/bin/42-initial_mysql_sync.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/42-initial_mysql_sync.sh"
$CLUSTER_HOME/bin/43-remote_reboot.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/43-remote_reboot.sh"

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
