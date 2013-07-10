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
node_counter=0
node_hostname=`hostname` || exitmsg "$SCRIPT_NAME: Error getting hostname"

hosts_file=`echo -e "127.0.0.1\t\tlocalhost\n"`
for node_ip in $ssh_node; do
	if (ip addr show | grep -q ${node_ip}); then
#		msg "$SCRIPT_NAME: $node_ip -> $node_hostname"
		hosts_file=`echo "$hosts_file"; echo -e "${node_ip}\t\t${node_hostname}"`
		continue
	else
		node_counter=$((node_counter+1))
	fi

#	msg "$SCRIPT_NAME: ${node_ip} -> c${node_counter}-${node_hostname}"
	hosts_file=`echo "$hosts_file"; echo -e "${node_ip}\t\tc${node_counter}-${node_hostname}"`
done

echo "$hosts_file"

node_counter=0
for node_ip in $ssh_node; do
	# if node_ip matches to any assigned ip to local interface, then skup
	if ( ip addr show | grep -q ${node_ip}/ ); then
		msg "$SCRIPT_NAME: Replace /etc/hosts on ${node_hostname}(${node_ip})"
		echo "$hosts_file" > /etc/hosts
		continue
	fi

	node_rootpass='1P@ssw0rd9'
	node_counter=$((node_counter+1))
	node_new_hostname="c${node_counter}-${node_hostname}"
	msg "$SCRIPT_NAME: Setting hostname of ${node_ip} to $node_new_hostname"

	# change hostname
	msg "$SCRIPT_NAME: Change hostname of $node_ip to $node_new_hostname"
	echo -n "$node_new_hostname" | SSHPASS=$node_rootpass \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		'cat - > /etc/hostname' || exitmsg 1 "$SCRIPT_NAME: Error on SSH to $node_ip"

	# replace /etc/hosts with generated hosts file
	msg "$SCRIPT_NAME: Replace /etc/hosts on ${node_new_hostname}(${node_ip})"
	echo "$hosts_file" | SSHPASS=$node_rootpass \
		sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		'cat - > /etc/hosts; reboot' || exitmsg 1 "$SCRIPT_NAME: Error on SSH to $node_ip"

#
#	node_hostname=`SSHPASS=$node_rootpass \
#		       sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
#		       'hostname'`
#	[ $? -eq 0 ] && echo -e "\thostname ${node_hostname};" >> $csync2_config
done

echo "$SCRIPT_NAME: SCRIPT OK"
exit 0
