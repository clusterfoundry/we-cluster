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

$CLUSTER_HOME/bin/51-modify_apache_config.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/51-modify_apache_config.sh"
$CLUSTER_HOME/bin/52-install_loadbalancer.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/52-install_loadbalancer.sh"
$CLUSTER_HOME/bin/53-configure_haproxy.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/53-configure_haproxy.sh"
$CLUSTER_HOME/bin/54-final_sync.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/54-final_sync.sh"
$CLUSTER_HOME/bin/55-start_local_services.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/55-start_local_services.sh"
$CLUSTER_HOME/bin/56-apache_suexec_fix.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/56-apache_suexec_fix.sh"
$CLUSTER_HOME/bin/57-enable_remote_services.sh || exitmsg 1 "Error running $CLUSTER_HOME/bin/57-enable_remote_services.sh"

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
