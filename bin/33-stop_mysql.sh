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

# kill mysqld
mysqld_pid=`pidof mysqld`

for pid in $mysqld_pid; do
	msg "Kill mysql pid $pid"
	kill $pid
done

# check if mysqld still runs
mysqld_pid=`pidof mysqld`
if [ x"$mysqld_pid" == x"" ]; then
	msg "$SCRIPT_NAME: SCRIPT OK"
	exit 0
else
	sleep 15
	for pid in $mysqld_pid; do
		msg "$SCRIPT_NAME: Kill(TERM) mysql pid $pid"
		kill -9 $pid
	done
fi

# if mysqld still runs, exit script
sleep 30
mysqld_pid=`pidof mysqld`
if [ x"$mysqld_pid" == x"" ]; then
	msg "$SCRIPT_NAME: SCRIPT OK"
	exit 0
else
	msg "$SCRIPT_NAME: Failed to stop mysqld"
	msg "$SCRIPT_NAME: SCRIPT ERROR"
	exit 1
fi

# no other choice, we need to issue reboot
# disable mysql service
msg "$SCRIPT_NAME: Disabling MySQL service on statup"
update-rc.d mysql disable
mv /etc/init/mysql.conf /etc/init/mysql.conf.disabed

msg "$SCRIPT_NAME: Issue REBOOT"
reboot
exit 0
