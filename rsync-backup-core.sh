#!/bin/bash
#set -o xtrace
#
# rsync a directory (recursively) to remote machine
#
# Notes:
# - ssh-keygen keys must be setup first
# - run as root
# - permissions are not maintained
#
# Usage: rsync_it.sh <directory>
# Author Shane - modified by Askar
# Script Update: update by Muzammel as per [APDC #92702]

E_BADARGS=65
# Must be root to run
if [[ ${UID} -ne 0 ]]; then
        echo "You must be root to run this script"
        exit $E_BADARGS
fi
# check for arguments
if [ -z $1 ];then
        echo "Usage: `basename $0` /<dir> <PathToExcludeFile>"
        exit $E_BADARGS
fi
#
SRC_HOSTNAME="c-golfcourses-palmsprings.awpdc.com"
DST_HOSTNAME="khap-b.awpdc.com"
DST_PATH="/var/awpdc_backups/${SRC_HOSTNAME}"
SSH_USER="bkp-user"
DST="${DST_HOSTNAME}:${DST_PATH}"
HOST=`awk -F. '{print $1}' <<< "$DST_HOSTNAME"`
#
# Check if DST_HOSTNAME is live, if yes then do the rsync else inject error to monitor
if ping -c 3 $DST_HOSTNAME >/dev/null 2>&1
then
SRC="${1}"

# Update by Muzammel to enable another exclude function [APDC #92702]
# Enable excludes files by enable any one from it, 
# if wish to pass exclude file as argument then pass file path as argument $2 in cron
# e.g /usr/local/bin/rsync-backup-mon-cron.sh /home /usr/local/etc/rsync-backup-excludes
# OR just enable EXCLUDE variable and set cron like below
# e.g /usr/local/bin/rsync-backup-mon-cron.sh /home

# EXCLUDES="/usr/local/etc/rsync-backup-excludes"
EXCLUDES=$2

RSYNC='rsync -e "ssh -l ${SSH_USER}" -avR --delete'
if [ -f ${EXCLUDES} ]; then
	RSYNC="${RSYNC} --exclude-from=${EXCLUDES}"
fi

function hline() {
        echo -e "================================================================================"
}

hline
echo -e "$(date) Synchronizing ${SRC} to ${DST}"
hline

eval $RSYNC $SRC $DST
err=$?

hline
if [ ${err} -eq 0 ]; then
	echo -e "$(date) Successful backup of ${SRC} to ${DST}"
	# Set timestamp on target dir
#	ssh -l ${SSH_USER} ${DST_HOSTNAME} "touch ${DST_PATH}"
else
	echo -e "$(date) Problems during backup of ${SRC} to ${DST}!   Exit code was: $?"
fi
hline
# Destination host is alive update monitor
  /usr/bin/injectExe rsync_bkp__${HOST} 0 W
else
# Destination host is dead update monitor
  /usr/bin/injectExe rsync_bkp__${HOST} 1 W
  exit $E_BADARGS
fi
