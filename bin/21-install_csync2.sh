#!/bin/bash -u

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
msg "$SCRIPT_NAME: Installing csync2 and dependencies"
apt-get install -y wget csync2 liblinux-inotify2-perl libnet-server-perl || exitmsg 1 "Unable to install packages"

# generate csync2 key
msg "$SCRIPT_NAME: Generating csync2 key. This may take a while."
[ -e $CSYNC2_KEY ] && rm -f $CSYNC2_KEY
csync2 -k $CSYNC2_KEY || exitmsg 1 "Cannot generate csync2 key"

# create backup directory
msg "$SCRIPT_NAME: Creating csync2 backup directory"
mkdir -p $CLUSTER_HOME/backup

# download csync2id
wget https://github.com/clusterfoundry/we-cluster/raw/master/bin/csync2id.pl -O $CLUSTER_HOME/bin/csync2id.pl || exitmsg 1 "Cannot download https://github.com/clusterfoundry/we-cluster/raw/master/csync2id.pl"
chmod +x $CLUSTER_HOME/bin/csync2id.pl

# install csync2id on upstart
msg "$SCRIPT_NAME: Generating csync2 configuration file"
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
msg "$SCRIPT_NAME: Installing csync2id.pl to upstart"
ln -s $CLUSTER_HOME/etc/upstart-csync2id.conf /etc/init/csync2id.conf

msg "SCRIPT OK"
exit 0
