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

LOCAL_MYSQL_SOCKET=/var/run/mysqld/mysqld.sock
LOCAL_MYSQL_PASS='1P@ssw0rd9'

cat << EOF | mysql -u root --socket $LOCAL_MYSQL_SOCKET -p"$LOCAL_MYSQL_PASS"
show grants for w_drup7@'%';
EOF

DB_USERS="w_drup7 admin"
for mysql_user in 
