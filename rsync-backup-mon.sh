#!/bin/bash
#
# Purpose: To inject rsync backup activity to monitor
# Author: Askar Ali Khan
# Mar 19, 06
#
FILE="/tmp/rsync_it.log"
RSYNC_CODES="/usr/local/etc/rsync-backup-exit-codes"
NO_FILE=69
E_BADARGS=65
TREE=$1
#
#
if [ -z "$1" ];then
        echo "Usage : `basename $0` /<dir>"
        exit $E_BADARGS
fi
#
# Check if log file is empty then exit.
if [ ! -s $FILE ];then
        exit 1
fi
#
if [ -f "$FILE" ]
then

BIGVAR=`tac $FILE | sed -n "/backup of ${TREE//\//\\/}/,/^$/p" | tac`
#
BYTE_SENT=`awk '/sent/{print $2}' <<< "$BIGVAR"`
#
# Converting bytes to KB
BYTE_SENT=$(echo "scale=2; $BYTE_SENT/1024.0" | bc -l) 
#
# If values starting with '.xx' then replace it with 0.xx
if [[ $BYTE_SENT = .* ]]
then
	BYTE_SENT="0$BYTE_SENT"
fi
#
# Injection of /etc
/usr/bin/injectExe backup__"$TREE"__send_KB ${BYTE_SENT} W
#
TOTAL_SIZE=`awk '/total size/{print $4}' <<< "$BIGVAR"`
#
# Converting bytes to KB
TOTAL_SIZE=$(echo "scale=2; $TOTAL_SIZE/1024" | bc -l)
#
if [[ $TOTAL_SIZE = .* ]]
then
        TOTAL_SIZE="0$TOTAL_SIZE"
fi
#
#
# Injection of total size
/usr/bin/injectExe backup__"$TREE"__total_size_KB ${TOTAL_SIZE} W
#
BYTES_PER_SEC=`awk '/sent/{print $7}' <<< "$BIGVAR"`
#
# Converting bytes to KB
BYTES_PER_SEC=$(echo "scale=2; $BYTES_PER_SEC/1024" | bc -l)
#
if [[ $BYTES_PER_SEC = .* ]]
then
        BYTES_PER_SEC="0$BYTES_PER_SEC"
fi
#
# Injecting Kbytes/sec
/usr/bin/injectExe backup__"$TREE"__KB/sec ${BYTES_PER_SEC} W
#
#RESULT=`awk '/backup of/{print $7}'<<< "$BIGVAR"`
#
RESULT=`echo "$BIGVAR" | grep "(code" | sed -e 's/.*(code //;s/).*$//'`
#
if [ -z "$RESULT" ]; then
        RESULT=0
fi
#
# Finding exact code for rsync exit status
REASON=`grep  -e "^$RESULT\b" $RSYNC_CODES | sed 's/^[0-9]*\s*//'`
#
# Injecting backup activity Result of each directory
/usr/bin/injectExe backup__"$TREE"__rsync_exit_code ${RESULT} W $REASON
#

echo "Byte send : $TREE : " $BYTE_SENT
echo "TOTAL SIZE: " $TOTAL_SIZE
echo "Byte/sec : " $BYTES_PER_SEC
echo "Result : " $RESULT
echo "Reason : " $REASON

else
        echo "File :$FILE not found"
        exit $NO_FILE
fi
#
# End script
