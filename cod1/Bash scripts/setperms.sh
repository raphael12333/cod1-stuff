#!/bin/sh
chown -R codserver:codserver /cod1/sd
find /cod1/sd -type d -exec chmod 0775 {} \;
find /cod1/sd -type f -exec chmod 0660 {} \;
chmod u+x /cod1/sd/cod_lnxded /cod1/sd/startmyserver.sh
chown codserver:codserver /cod1/sd/codextended.so
chmod 660 /cod1/sd/codextended.so
cd main/
chmod 660 CoDaM_MiscMod.cfg ___CoDaM_MiscMod.pk3 miscmod_bans.dat miscmod_reports.dat
chown codserver:codserver CoDaM_MiscMod.cfg ___CoDaM_MiscMod.pk3 miscmod_bans.dat miscmod_reports.dat
chmod u+x ../setperms.sh
