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

touch $CLUSTER_HOME/bin/startup.sh
#echo "$CLUSTER_HOME/bin/00-prepare_devpanel.sh" > $CLUSTER_HOME/bin/startup.sh
echo "touch /tmp/pogi" > $CLUSTER_HOME/bin/startup.sh

chmod +x $CLUSTER_HOME/bin/startup.sh
#cat /etc/rc.local | grep -v "exit 0" > /etc/rc.local

# empty file
> /etc/rc.local
echo "$CLUSTER_HOME/bin/startup.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local


msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
