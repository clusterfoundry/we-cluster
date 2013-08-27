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

# disable taskd and dbmgr from upstart
for service in taskd devpanel-dbmgr; do
	msg "Disable $service from upstart"
	mv /etc/init/${service}.conf /etc/init/${service}.conf.disabled || msg "$SCRIPT_NAME: Disable ${service} failed"
done

# disable apache from /etc/init.d/
for service in apache2 devpanel-dbmgr; do
	msg "Disable $service on /etc/init.d/"
	update-rc.d apache2 disable || msg "$SCRIPT_NAME: Disable ${service} failed"
done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
