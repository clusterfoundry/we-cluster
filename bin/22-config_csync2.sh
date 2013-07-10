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

# create temporary config file
csync2_config=`mktemp /tmp/csync2.cfg.XXXXX` || exitmsg 1 "Error creating temporary file"
msg "$SCRIPT_NAME: Temporary file $csync2_config created"

# 1st part of csync2 config
msg "Generating 1st part of csync2 config"
cat << EOF > $csync2_config
nossl * *;

group $CLUSTER_NAME {
EOF

CSYNC_CONFIG_CONTENTS=
storage_node=`getNodeInfo STORAGE | awk -F: '{print $1}'`
for node_ip in $storage_node; do
	msg "Connecting to $node_ip"
	node_rootpass='1P@ssw0rd9'
	node_hostname=`SSHPASS=$node_rootpass \
		       sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$node_ip \
		       'hostname'`
	msg "$SCRIPT_NAME: ${node_ip} -> ${node_hostname}"
	[ $? -eq 0 ] && echo -e "\thostname ${node_hostname};" >> $csync2_config
done

# create include on CSYNC2 config
# add empty line
msg "Constructing csync2 configuration 'include' block"
echo >> $csync2_config
includes=`echo "$CSYNC2_INCLUDE" | sed 's/|/\n/g'`
for include in $includes; do
	#TODO: Identify if file, dir or symlink.
	echo -e "\tinclude $include;" >> $csync2_config
done

# write bottom part of the config
msg "Generating last part of csync2 config"
echo "$includes"
cat << EOF >> $csync2_config

	key $CSYNC2_KEY;
	auto younger;
}
EOF

# copy csync2 config to $CLUSTER_HOME/etc/
msg "Save configuration to $CLUSTER_HOME/etc/csync2-$CLUSTER_NAME.cfg"
cat $csync2_config > $CLUSTER_HOME/etc/csync2-$CLUSTER_NAME.cfg

# create symbolic linkCLUSTER_NAME.cfg"
msg "Create symbolic link to /etc/csync2.cfg"
rm /etc/csync2.cfg
ln -s $CLUSTER_HOME/etc/csync2-$CLUSTER_NAME.cfg /etc/csync2.cfg

msg "$SCRIPT_NAME: CSYNC2 Temporary Config File: $csync2_config"
msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
