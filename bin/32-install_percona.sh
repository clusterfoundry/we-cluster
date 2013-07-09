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

# add percona apt key
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A || exitmsg 1 "Error adding Percona APT key"

# add percona repository
source /etc/lsb-release || exitmsg 1 "Error getting OS version"
[ $DISTRIB_CODENAME ] || exitmsg 1 "Error getting OS version"

echo "deb http://repo.percona.com/apt $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt $DISTRIB_CODENAME main" >> /etc/apt/sources.list.d/percona.list

# update repository
apt-get update

# install percona xtradb cluster
apt-get install -y percona-xtradb-cluster-server-5.5 php5-mysql
