#!/bin/bash
DEBIAN_FRONTEND=noninteractive

# quick fix: change mysql server
# for drupal
sed "s/'127.0.0.1'/'$1'/Ig" -i /home/clients/websites/*/public_html/*/sites/default/settings.php
exit 0

# enable apache2
update-rc.d apache2 enable

# enable mysql
update-rc.d mysql enable
echo "SCRIPT OK"
reboot >/dev/null 2>&1
