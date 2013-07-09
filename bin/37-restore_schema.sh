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

# -rw-r--r-- 1 root root 1355525 Jul  8 02:17 ../export/mysql/mysqlschema.drupal.sql
# -rw-r--r-- 1 root root     413 Jul  8 02:17 ../export/mysql/mysqluser.admin.JQ==.sql
# -rw-r--r-- 1 root root     568 Jul  8 02:17 ../export/mysql/mysqluser.root.bG9jYWxob3N0.sql
# -rw-r--r-- 1 root root     520 Jul  8 02:17 ../export/mysql/mysqluser.w_d7a1.JQ==.sql

# load schema first
mysql_cmd="mysql -u root"
schema_files=`find $CLUSTER_HOME/export/mysql -type f -name "mysqlschema.*.sql"`
for file in $schema_files; do
	mysql_schema=`basename $file | awk -F. '{print $2}'`
	msg "Creating schema $mysql_schema"
	$mysql_cmd -e "CREATE DATABASE ${mysql_schema};" || exitmsg 1 "Error creating schema $mysql_schema"

	msg "Restoring sql file $file and migrating from MyISAM to InnoDB"
	cat $file | sed 's/ENGINE=MyISAM/ENGINE=InnoDB/Ig' | $mysql_cmd $mysql_schema || exitmsg 1 "Error restoring $file"
done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0


