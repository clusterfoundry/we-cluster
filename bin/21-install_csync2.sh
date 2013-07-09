#!/bin/bash -uv

CLUSTER_HOME=/opt/webenabled/cluster
CLUSTER_CONFIG_FILE=$CLUSTER_HOME/etc/cluster.conf
SCRIPT_LIBRARY=$CLUSTER_HOME/lib/functions.sh
SCRIPT_ABSPATH=`readlink -f $0`
SCRIPT_DIR=`dirname "$SCRIPT_ABSPATH"`
SCRIPT_NAME=`basename $0`

# load functions
source $SCRIPT_LIBRARY || exit 2
# load configurations
source "$CLUSTER_CONFIG_FILE" || exit 2

# install csync2 and other csync2id dependencies
apt-get install wget csync2 liblinux-inotify2-perl libnet-server-perl || exit 1

# generate csync2 key
csync2 -k $CSYNC2_KEY || exit 1

# create backup directory
mkdir -p $CLUSTER_HOME/backup

# download csync2id
wget https://github.com/clusterfoundry/we-cluster/raw/master/csync2id.pl -O $CLUSTER_HOME/bin/csync2id.pl || exit 1
chmod +x $CLUSTER_HOME/bin/csync2id.pl

# install csync2id on upstart
cat << EOF > $CLUSTER_HOME/etc/upstart-csync2id.conf
# csync2id.pl - inotify watcher that triggers csync2
#

description "Inotify helper for csync2"

start on (started network-interface
          or started network-manager
          or started networking)

stop on runlevel [!023456]

console log
expect fork
respawn

exec $CLUSTER_HOME/bin/csync2id.pl
EOF

# install upstart script
ln -s CLUSTER_HOME/etc/upstart-csync2id.conf /etc/init/csync2id.conf

msg "SCRIPT OK"
exit 0
