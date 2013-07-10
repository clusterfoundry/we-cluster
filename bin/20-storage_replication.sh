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

$CLUSTER_HOME/bin/21-install_csync2.sh || exitcode 1 "Error running $CLUSTER_HOME/bin/21-install_csync2.sh"
$CLUSTER_HOME/bin/22-config_csync2.sh || exitcode 1 "Error running $CLUSTER_HOME/bin/22-config_csync2.sh"
$CLUSTER_HOME/bin/23-initial_sync.sh || exitcode 1 "Error running $CLUSTER_HOME/bin/23-initial_sync.sh"

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
