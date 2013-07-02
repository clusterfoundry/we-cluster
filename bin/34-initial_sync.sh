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

includes=`echo "$CSYNC2_INCLUDE" | sed 's/|/ /g'`
echo $includes
#for include in $includes; do
#        #TODO: Identify if file, dir or symlink.
#        echo -e "\tinclude $include;"
#done

storage_node=`getNodeInfo STORAGE | awk -F: '{print $1}'`
for node_ip in $storage_node; do
	node_rootpass='1P@ssw0rd9'
	echo tar -C / -czf - $includes
	echo SSHPASS=$node_rootpass sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"tar -C / -xzf - || echo \"SCRIPT ERR \$?\""
done