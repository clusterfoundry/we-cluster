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

# enable mysql services
msg "Enable and start Percona XtraDB Cluster"
update-rc.d mysql enable
service mysql start

# enable apache2 services
msg "Enable and start Apache2"
update-rc.d apache2 enable
service apache2 start

# enable haproxy service
msg "Enable and start HAProxy"
update-rc.d haproxy enable
service haproxy start

# enable taskd
msg "Enable and start devPanel taskd"
mv /etc/init/taskd.conf.disabled /etc/init/taskd.conf
initctl start taskd

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
