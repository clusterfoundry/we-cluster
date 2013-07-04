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
sql="select concat(user,'|',host,'|',password) from mysql.user where user != '' and host != ''"
mysql_cmd="mysql -u${DP_APP_DB_USER} -p${DP_APP_DB_PASS} --skip-column-names -AB"
mysql_users=`$mysql_cmd -e "$sql"` || exit 1

# NOTE: This block should be put on 50-*.sh
# do a cleanup on export directory, create new sql files
[ -d "$CLUSTER_HOME/export/mysql" ] && rm -rf "$CLUSTER_HOME/export/mysql"
mkdir -p "$CLUSTER_HOME/export/mysql"

# create user statements, export hashed passwords and export grants
for line in $mysql_users; do
	db_user=`echo "$line" | awk -F\| '{print $1}'`
	db_host=`echo "$line" | awk -F\| '{print $2}'`
	db_pass=`echo "$line" | awk -F\| '{print $3}'`

	encoded_host=`echo -n "${db_host}" | base64`
	user_filename="$CLUSTER_HOME/export/mysql/mysqluser.${db_user}.${encoded_host}.sql"

	# create user
	msg "${db_user}@${db_host} -> CREATE USER"
	echo "CREATE USER '${db_user}'@'${db_host}';" > "$user_filename"

	# update password
	msg "${db_user}@${db_host} -> UPDATE PASSWORD"
	echo "UPDATE mysql.user SET password='${db_pass}' WHERE user='${db_user}' and host='${db_host}';" >> "$user_filename"

	# grants
	msg "${db_user}@${db_host} -> SHOW GRANTS"
	$mysql_cmd -e "SHOW GRANTS FOR '${db_user}'@'${db_host}';" | sed 's/$/;/g' >> "$user_filename"
done

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
