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

# backup old config
cp -pR /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.old || exitmsg 1 "Cannot backup /etc/haproxy/haproxy.cfg"

web_node=`getNodeInfo WEB | awk -F: '{print $1}'`
haproxy_template="$CLUSTER_HOME/lib/haproxy.cfg.template"
cat $haproxy_template > $CLUSTER_HOME/etc/haproxy.cfg

# forwarding for HTTP
node_http_port=10080
echo    "listen HTTP_webfarm1 0.0.0.0:80" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\tmode http" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\toption httplog" >> $CLUSTER_HOME/etc/haproxy.cfg
for node_ip in $web_node; do
	node_pass='1P@ssw0rd9'
	node_alias=`echo "$node_ip" | sed 's/\./-/g'`

	echo -e "\tserver HTTP_${node_alias} ${node_ip}:${node_http_port} check" >> $CLUSTER_HOME/etc/haproxy.cfg
done
echo '' >> $CLUSTER_HOME/etc/haproxy.cfg

# forwarding for HTTPS
node_https_port=10443
echo    "listen HTTPS_webfarm1 0.0.0.0:443" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\tmode tcp" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\toption tcplog" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\toption ssl-hello-chk" >> $CLUSTER_HOME/etc/haproxy.cfg
for node_ip in $web_node; do
	node_pass='1P@ssw0rd9'
	node_alias=`echo "$node_ip" | sed 's/\./-/g'`

	echo -e "\tserver HTTPS_${node_alias} ${node_ip}:${node_https_port} check" >> $CLUSTER_HOME/etc/haproxy.cfg
done
echo '' >> $CLUSTER_HOME/etc/haproxy.cfg

# forwarding for MySQL
node_mysql_port=3306
echo    "listen mysqlfarm1 0.0.0.0:4000" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\tmode tcp" >> $CLUSTER_HOME/etc/haproxy.cfg
echo -e "\toption tcplog" >> $CLUSTER_HOME/etc/haproxy.cfg
for node_ip in $web_node; do
	node_pass='1P@ssw0rd9'
	node_alias=`echo "$node_ip" | sed 's/\./-/g'`

	echo -e "\tserver MYSQL_${node_alias} ${node_ip}:${node_mysql_port} check" >> $CLUSTER_HOME/etc/haproxy.cfg
done

# create symbolic link
msg "$SCRIPT_NAME: Install new haproxy configuration"
[ -e /etc/haproxy/haproxy.cfg ] && rm -f /etc/haproxy/haproxy.cfg
ln -s $CLUSTER_HOME/etc/haproxy.cfg /etc/haproxy/haproxy.cfg

msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
