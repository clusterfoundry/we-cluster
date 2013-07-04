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

# get first app, multiple app not supported
DP_APP=`getDPApps | grep ":mysql:" | head -n1`
DP_APP_DB_OWNER=`echo "$DP_APP" | awk -F: '{print $1}'`
DP_APP_DB_HOME=`echo "$DP_APP" | awk -F: '{print $4}'`
DP_APP_DB_SOCKET=`[ -S "$DP_APP_DB_HOME/mysql.sock" ] && echo "$DP_APP_DB_HOME/mysql.sock"`
DP_APP_DB_USER=root
DP_APP_DB_PASS=`getDP_rootPass $DP_APP_DB_OWNER`

vars=`dumpVars DP_APP DP_APP_DB_OWNER DP_APP_DB_HOME DP_APP_DB_SOCKET DP_APP_DB_USER DP_APP_DB_PASS`
#echo "$vars"
mysql_vars=`echo "$vars" | sed 's/$/ \\\\/g'`

eval "$mysql_vars
$CLUSTER_HOME/bin/52-dump_table_grants.sh"

eval "$mysql_vars
$CLUSTER_HOME/bin/53-dump_schemas.sh"

echo "$SCRIPT_NAME: SCRIPT OK"
exit 0
