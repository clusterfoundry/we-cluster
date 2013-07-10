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

# uninstall mysql
apt-get remove --purge -y mysql-client-5.5 mysql-client-core-5.5 mysql-common mysql-server mysql-server-5.5 mysql-server-core-5.5

# move configuration file
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.old
mv /etc/my.cnf /etc/my.cnf.old

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
