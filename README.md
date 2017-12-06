1) placed .sh files in /usr/local/bin and rsync-backup-cron in /etc/cron.d/ and place rsync-backup-exit-codes and rsync-backup-excludes in /usr/local/etc/ dir.

2) Edit  rsync-backup-core.sh for source ,destination and backup user, also generate ssh keys on source hosts and placed on destination host under backup user.

change the values of following directives.
SRC_HOSTNAME="c-golfcourses-palmsprings.awpdc.com"
DST_HOSTNAME="khap-b.awpdc.com"
DST_PATH="/var/awpdc_backups/${SRC_HOSTNAME}"
SSH_USER="bkp-user"


3) Run one line from cron file to ensure and set the timings and locations in cron accordingly.
