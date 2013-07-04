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

# construct sql statement
sql="show databases;"
mysql_cmd="mysql -u${DP_APP_DB_USER} -p${DP_APP_DB_PASS} --skip-column-names -AB"
mysql_schemas_raw=`$mysql_cmd -e "$sql"` || exit 1
mysql_schemas=`echo "$mysql_schemas_raw" | egrep -v "^(information_schema|performance_schema|mysql|test)$"`

# create user statements, export hashed passwords and export grants
for line in $mysql_schemas; do
	db_schema="$line"
	user_filename="$CLUSTER_HOME/export/mysql/mysqlschema.${db_schema}.sql"

	msg "Dumping schema $db_schema to $user_filename"
	mysqldump -u${DP_APP_DB_USER} -p${DP_APP_DB_PASS} --databases ${db_schema} > $user_filename
done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
