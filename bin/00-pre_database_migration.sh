#!/bin/bash -u
#
# Script Name: Pre-Database Migration
#
# Description: Retrieves mysql root passwords from
#              cluster.conf and dumps users and schemas.
#              This is also the parent script that calls
#              other sub-scripts (database backup)

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
echo "$vars"
mysql_vars=`echo "$vars" | sed 's/$/ \\\\/g'`

next_script_name="01-dump_table_grants.sh"
eval "$mysql_vars
$CLUSTER_HOME/bin/$next_script_name" || exitmsg 1 "Error on $next_script_name script"

next_script_name="02-dump_schemas.sh"
eval "$mysql_vars
$CLUSTER_HOME/bin/$next_script_name" || exitmsg 1 "Error on $next_script_name script"

next_script_name="03-disable_services.sh"
$CLUSTER_HOME/bin/$next_script_name || exitmsg 1 "Error on $next_script_name script"

# install next script before reboot
next_script_name="04-continue_script_on_reboot.sh"
$CLUSTER_HOME/bin/$next_script_name || exitmsg 1 "Error on $next_script_name script"

# reboot
msg "$SCRIPT_NAME: Reboot machine"
msg "$SCRIPT_NAME: SCRIPT OK"
reboot
