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

$CLUSTER_HOME/bin/31-uninstall_mysql.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/31-uninstall_mysql.sh"
$CLUSTER_HOME/bin/32-install_percona.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/32-install_percona.sh"
$CLUSTER_HOME/bin/33-stop_mysql.sh || exitmsg 1 "Error executing$CLUSTER_HOME/bin/33-stop_mysql.sh"
$CLUSTER_HOME/bin/34-configure_mysql_cluster.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/34-configure_mysql_cluster.sh"
$CLUSTER_HOME/bin/35-backup_old_mysql.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/35-backup_old_mysql.sh"
$CLUSTER_HOME/bin/36-start_master_mysql.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/36-start_master_mysql.sh"
$CLUSTER_HOME/bin/37-restore_schema.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/37-restore_schema.sh"
$CLUSTER_HOME/bin/38-restore_users.sh || exitmsg 1 "Error executing $CLUSTER_HOME/bin/38-restore_users.sh"
$CLUSTER_HOME/bin/39-stop_mysql || exitmsg 1 "Error executing $CLUSTER_HOME/bin/39-stop_mysql"

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
