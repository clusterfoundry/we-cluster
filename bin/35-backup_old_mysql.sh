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

# backup old mysql data
mysql_datadir=/var/lib/mysql
mysql_backup_archive=/var/lib/mysql.tgz
[ -e $mysql_backup_archive ] && rm -f $mysql_backup_archive
msg "$SCRIPT_NAME: Backup old MySQL data"
tar -cvzf $mysql_backup_archive /var/lib/mysql

# delete old mysql data
msg "$SCRIPT_NAME: Delete $mysql_datadir"
rm -rf $mysql_datadir/* >/dev/null 2>&1

# create new mysql dir
mysql_uid=mysql
mysql_gid=mysql
msg "$SCRIPT_NAME: Create $mysql_datadir"
mkdir -p $mysql_datadir || exitmsg 1 "Unable to create $mysql_datadir"
chown -R "${mysql_uid}:${mysql_gid}" $mysql_datadir

# create blank database
mysql_defaults_file=/etc/my.cnf
msg "$SCRIPT_NAME: Installing blank database"
mysql_install_db --defaults-file=$mysql_defaults_file || exitmsg 1 "Unable to create blank database"

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
