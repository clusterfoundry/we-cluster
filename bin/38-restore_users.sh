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

# load users (exclude root)
mysql_cmd="mysql -u root"
users_files=`find $CLUSTER_HOME/export/mysql -type f -name "mysqluser.*.sql" | grep -v '/mysqluser.root.'`
for file in $users_files; do
	mysql_user=`basename $file | awk -F. '{print $2}'`
	mysql_host=`basename $file | awk -F. '{print $3}' | base64 -d`

	msg "Creating user, grants and password for ${mysql_user}@${mysql_host}"
	( cat $file; echo "FLUSH PRIVILEGES;" ) | egrep -v "^0;" | $mysql_cmd || exitmsg 1 "Error restoring $file"
done

# create SST user
#[ $MYSQL_CLUSTER_REPLICATION_AUTH ] || exitmsg 1 "MYSQL_CLUSTER_REPLICATION_AUTH not found in $CLUSTER_HOME/etc/cluster.conf"
#sst_auth=$MYSQL_CLUSTER_REPLICATION_AUTH

# set root password
msg "Set root password"

#( cat $CLUSTER_HOME/export/mysql/mysqluser.root.*.sql; echo "FLUSH PRIVILEGES;" ) \
#	| grep -vi "CREATE USER 'root'@" | egrep -v "^0;" | $mysql_cmd || exitmsg 1 "Error setting root password"

#( echo "CREATE USER 'root'@'%';"
#echo "GRANT ALL ON *.* to 'root'@'%';"
#echo "UPDATE mysql.user set password=password('1P@ssw0rd9') where user='root' and host='%'; FLUSH PRIVILEGES;" ) 
cat - << EOF | $mysql_cmd || exitmsg 1 "Error setting root password"
CREATE USER 'root'@'%';
GRANT ALL ON *.* to 'root'@'%';
UPDATE mysql.user set password=password('1P@ssw0rd9')
    WHERE user='root';

EOF

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
