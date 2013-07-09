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

ssh_node=`getNodeInfo SSH | awk -F: '{print $1}'`
for node_ip in $ssh_node; do
        # if node_ip matches to any assigned ip to local interface, then skip
	if ( ip addr show | grep -q ${node_ip}/ ); then
		msg "$SCRIPT_NAME: IP ${node_ip} matches local IP. Skipping..."
		continue
	fi

	node_pass='1P@ssw0rd9'

	# add percona repository
	msg "$SCRIPT_NAME: Add Percona APT Repository"
	cat "${SCRIPT_DIR}/disable_services.sh" | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"cat - > /tmp/disable_services.sh; chmod +x /tmp/disable_services.sh; /tmp/disable_services.sh" | sed 's/^/['$node_ip'] >> /g'

done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
