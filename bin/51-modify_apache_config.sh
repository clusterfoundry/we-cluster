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

# chage ports on /etc/apache2/ports.conf
msg "$SCRIPT_NAME: Backup /etc/apache2/ports.conf"
cp -pR /etc/apache2/ports.conf /etc/apache2/ports.conf.old || exitmsg 1 "$SCRIPT_NAME: Cannot create backup of ports.conf"
msg "$SCRIPT_NAME: Change port from 80 -> 10080, 443 -> 10443"
cat /etc/apache2/ports.conf.old \
	| sed 's/Listen 80$/Listen 10080/Ig' | sed 's/NameVirtualHost \*:80$/NameVirtualHost *:10080/Ig' \
	| sed 's/Listen 443$/Listen 10443/Ig' | sed 's/NameVirtualHost \*:443$/NameVirtualHost *:10443/Ig' > /etc/apache2/ports.conf

# change ports on /opt/webenabled/compat/apache_include/virtwww.conf
msg "$SCRIPT_NAME: Backup /opt/webenabled/compat/apache_include/virtwww.conf"
cp -pR /opt/webenabled/compat/apache_include/virtwww.conf /opt/webenabled/compat/apache_include/virtwww.conf.old || exitmsg 1 "$SCRIPT_NAME: Cannot create backup of virtwww.conf"
msg "$SCRIPT_NAME: Change port from 80 -> 10080"
cat /opt/webenabled/compat/apache_include/virtwww.conf.old \
	| sed 's/\$IP:80/$IP:10080/Ig' \
	| sed 's/\$IP:443/$IP:10443/Ig' > /opt/webenabled/compat/apache_include/virtwww.conf

# change ports on /opt/webenabled/compat/apache_include/vhost-ssl.conf
msg "$SCRIPT_NAME: Backup /opt/webenabled/compat/apache_include/vhost-ssl.conf"
cp -pR /opt/webenabled/compat/apache_include/vhost-ssl.conf /opt/webenabled/compat/apache_include/vhost-ssl.conf.old || exitmsg 1 "$SCRIPT_NAME: Cannot create backup of vhost-ssl.conf"
msg "$SCRIPT_NAME: Change port from 80 -> 10080"
cat /opt/webenabled/compat/apache_include/vhost-ssl.conf.old \
	| sed 's/ \$IP:80/ \$IP:10080/Ig' \
	| sed 's/ \$IP:443/ \$IP:10443/Ig' > /opt/webenabled/compat/apache_include/vhost-ssl.conf

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
