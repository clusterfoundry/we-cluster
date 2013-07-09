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

# install haproxy
apt-get install haproxy || exitmsg 1 "$SCRIPT_NAME: Error installing haproxy"

# enable haproxy
sed 's/ENABLED=0/ENABLED=1/g' -i /etc/default/haproxy

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
