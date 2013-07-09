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

mysql_config=`cat $MYSQL_CONF_TEMPLATE`

# change bind-address
mysql_bind_address='0.0.0.0'
mysql_config=`echo "$mysql_config" | sed 's/|bind-address|/'$mysql_bind_address'/g'`

# change port
mysql_port=3306
mysql_config=`echo "$mysql_config" | sed 's/|port|/'$mysql_port'/g'`

# change wsrep_cluster_name
mysql_wsrep_cluster_name=db-${CLUSTER_NAME}
mysql_config=`echo "$mysql_config" | sed 's/|wsrep_cluster_name|/'$mysql_wsrep_cluster_name'/g'`

# change wsrep_provider
mysql_wsrep_provider=`find /usr -name libgalera_smm.so` || exitmsg 1 "Cannot find libgalera_smm.so"
mysql_config=`echo "$mysql_config" | sed 's:|wsrep_provider|:'$mysql_wsrep_provider':g'`

# change wsrep_sst_method
mysql_wsrep_sst_method=xtrabackup
mysql_config=`echo "$mysql_config" | sed 's/|wsrep_sst_method|/'$mysql_wsrep_sst_method'/g'`

# change wsrep_sst_auth
mysql_wsrep_sst_auth="root:1P@ssw0rd9"
mysql_config=`echo "$mysql_config" | sed 's/|wsrep_sst_auth|/'$mysql_wsrep_sst_auth'/g'`

# change wsrep_cluster_address
mysql_nodes=`getNodeInfo MYSQL | awk -F: '{print $1}'`
mysql_master=`echo "$mysql_nodes" | head -n1`

# construct wsrep_cluster_address based on IP listed on configuration
mysql_remote_wsrep_cluster_address=
for node_ip in $mysql_nodes; do
	mysql_remote_wsrep_cluster_address=`echo -n "$mysql_remote_wsrep_cluster_address"; echo -n ",gcomm:\/\/${node_ip}"`
done
mysql_remote_wsrep_cluster_address=`echo "$mysql_remote_wsrep_cluster_address" | sed 's/^,//g'`
mysql_remote_config=`echo "$mysql_config" | sed 's/|wsrep_cluster_address|/'$mysql_remote_wsrep_cluster_address'/g'`

# construct config for master
mysql_wsrep_cluster_address=
if ( ip addr show | grep -q ${mysql_master}/ ); then
	mysql_wsrep_cluster_address='gcomm:\/\/'
	msg "$SCRIPT_NAME: Local IP($mysql_master) matches the master, setting wsrep_cluster_address to 'gcomm://'"
fi
mysql_wsrep_cluster_address=`echo "$mysql_wsrep_cluster_address" | sed 's/^,//g'`
mysql_config=`echo "$mysql_config" | sed 's/|wsrep_cluster_address|/'$mysql_wsrep_cluster_address'/g'`

echo "$mysql_remote_config" > /etc/my-slave.cnf

# save configuration file
echo "$mysql_config" > /etc/my.cnf

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
