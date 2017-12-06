#!/bin/bash
#
E_BADARGS=65
#
# Must be root to run
if [[ ${UID} -ne 0 ]]; then
        echo "You must be root to run this script"
        exit 1
fi
# check for shell argument
if [ -z $1 ];then
        echo "Usage: `basename $0` /<dir> <PathToExcludeFile>"
        exit $E_BADARGS
fi
#
# Rsync /<dir>.
if [ -z $2 ];then
 /usr/local/bin/rsync-backup-core.sh $1  >> /tmp/rsync_it.log 2> /dev/null
else
 /usr/local/bin/rsync-backup-core.sh $1 $2 >> /tmp/rsync_it.log 2> /dev/null
fi
#
if [ $? -eq 0 ]
then
# Injecting items of /<dir> to monitor.
 /usr/local/bin/rsync-backup-mon.sh $1 >> /tmp/backup_monitor.log 2> /dev/null
else
 exit 1
fi
#
# End script

