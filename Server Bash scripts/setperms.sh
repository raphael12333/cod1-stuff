#!/bin/sh
chown -R codserver:codserver /cod1/sd
find /cod1/sd -type d -exec chmod 0775 {} \;
find /cod1/sd -type f -exec chmod 0660 {} \;
chmod u+x cod_lnxded startmyserver.sh
chown codserver:codserver codextended.so
chmod 660 codextended.so
cd main/
chmod 660 CoDaM_MiscMod.cfg ___CoDaM_MiscMod.pk3 miscmod_bans.dat miscmod_reports.dat
chown codserver:codserver CoDaM_MiscMod.cfg ___CoDaM_MiscMod.pk3 miscmod_bans.dat miscmod_reports.dat
chmod u+x ../setperms.sh
