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
cp -pR /etc/haproxy/haproxy.cfg /etc/haproxy.cfg.old || exitmsg 1 "Cannot backup /etc/haproxy/haproxy.cfg"


web_node=`getNodeInfo WEB | awk -F: '{print $1}'`
haproxy_template="$CLUSTER_HOME/lib/haproxy.cfg.template"
cat $haproxy_template

# forwarding for HTTP
node_http_port=10080
echo    "listen HTTP_webfarm1 0.0.0.0:80"
echo -e "\tmode http"
echo -e "\toption httplog"
for node_ip in $web_node; do
	node_pass='1P@ssw0rd9'
	node_alias=`echo "$node_ip" | sed 's/\./-/g'`

	echo -e "\tserver HTTP_${node_alias} ${node_ip}:${node_http_port} check"
done
echo ''

# forwarding for HTTPS
node_https_port=10443
echo    "listen HTTPS_webfarm1 0.0.0.0:443"
echo -e "\tmode tcp"
echo -e "\toption tcplog"
echo -e "\toption ssl-hello-chk"
for node_ip in $web_node; do
	node_pass='1P@ssw0rd9'
	node_alias=`echo "$node_ip" | sed 's/\./-/g'`

	echo -e "\tserver HTTPS_${node_alias} ${node_ip}:${node_https_port} check"
done
echo ''


msg "$SCRIPT_NAME: SCRIPT OK"
exit 0
