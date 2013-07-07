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
for service in taskd dbmgr; do
	msg "Disable $service from upstart"
	mv /etc/init/${service}.conf /etc/init.d/${service}.conf.disabled || msg 1 "$SCRIPT_NAME: Disable ${service} failed"
done

# disable apache from /etc/init.d/
for service in apache2; do
	msg "Disable $service on /etc/init.d/"
	update-rc.d apache2 disable || msg "$SCRIPT_NAME: Disable ${service} failed"
done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0

## stop apache
#for i in {1..10}; do
#	killall apache2
#	sleep 2
#	pidof apache2 || break
#	echo "Apache not stopped, going to loop #$i"
#done
#
## stop mysql
#for i in {1..10}; do
#	killall mysqld
#	sleep 2
#	pidof mysqld || break
#	echo "mysqld not stopped, going to loop #$i"
#done
#
## stop mysqld_safe
#for i in {1..10}; do
#	killall mysqld_safe
#	sleep 2
#	pidof mysqld_safe || break
#	echo "mysqld_safe not stopped, going to loop #$i"
#done
