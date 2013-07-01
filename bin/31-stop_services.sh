#!/bin/bash -uv

CLUSTER_CONFIG_FILE=/opt/webenabled/cluster/etc/cluster.conf
SCRIPT_LIBRARY=/opt/webenabled/cluster/lib/functions.sh
SCRIPT_ABSPATH=`readlink -f $0`
SCRIPT_DIR=`dirname "$SCRIPT_ABSPATH"`
SCRIPT_NAME=`basename $0`

# load functions
source $SCRIPT_LIBRARY || exit 2
# load configurations
source "$CLUSTER_CONFIG_FILE" || exit 2


# stop apache
for i in {1..10}; do
	killall apache2
	sleep 2
	pidof apache2 || break
	echo "Apache not stopped, going to loop #$i"
done

# stop mysql
for i in {1..10}; do
	killall mysqld
	sleep 2
	pidof mysqld || break
	echo "mysqld not stopped, going to loop #$i"
done

# stop mysqld_safe
for i in {1..10}; do
	killall mysqld_safe
	sleep 2
	pidof mysqld_safe || break
	echo "mysqld_safe not stopped, going to loop #$i"
done
