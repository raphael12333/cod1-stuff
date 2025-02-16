#!/bin/sh
chown -R codserver:codserver /data/myserver
find /data/myserver -type d -exec chmod 0775 {} \;
find /data/myserver -type f -exec chmod 0660 {} \;
chmod u+x cod_lnxded startmyserver.sh
chown codserver:codserver iw1x.so
chmod 660 iw1x.so
chmod u+x setperms.sh