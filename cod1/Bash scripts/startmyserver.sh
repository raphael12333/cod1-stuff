#!/bin/sh
exec setpriv --reuid=codserver --regid=codserver --clear-groups sh -- <<- 'COD'
	HOME=/cod1/sd
	exec env - LD_PRELOAD=$HOME/codextended.so $HOME/cod_lnxded +set fs_homepath $HOME +set fs_basepath $HOME +set net_ip X.X.X.X +set net_port 28960 +exec myserver.cfg +map mp_harbor < /dev/tty 2>&1 | tee -a codserver.log
COD
