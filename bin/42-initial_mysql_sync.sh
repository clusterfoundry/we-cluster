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
	mysql_files="/var/lib/mysql /etc/init.d/mysql /etc/mysql /etc/my.cnf /etc/my-slave.cnf"
	mysql_tar_file="/var/lib/mysqlsync.tgz"

	# create tgz file
	[ -e $mysql_tar_file ] && rm -f $mysql_tar_file
	tar -czf $mysql_tar_file $mysql_files || exitmsg 1 "$SCRIPT_NAME: Error creating TGZ file $mysql_tar_file"

	wait_for_ssh $node_ip 22 5 20
	# transfer mysql tgz file
	msg "$SCRIPT_NAME: Transferring $mysql_tar_file to $node_ip"
	cat "$mysql_tar_file" | SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"tar -C / -xzf - || echo 'SCRIPT ERROR'" | sed 's/^/['$node_ip'] >> /g'

	wait_for_ssh $node_ip 22 5 20
	# change configuration of slave db's
	msg "$SCRIPT_NAME: Link my.cnf -> my-slave.cnf"
	SSHPASS="$node_pass" \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		"rm /etc/my.cnf; ln -s /etc/my-slave.cnf /etc/my.cnf" | sed 's/^/['$node_ip'] >> /g'

done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
