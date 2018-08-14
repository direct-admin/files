#!/bin/sh
wget -N http://directadmin.ga/key/license.key -O /usr/local/directadmin/conf/license.key
service crond restart
service directadmin restart
service httpd restart