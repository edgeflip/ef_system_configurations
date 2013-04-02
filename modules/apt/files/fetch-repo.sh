3#!/bin/bash

# fetch-repo.sh: Update the local apt repo from S3

ME=`basename $0`;
LOCK_FILE="/var/lock/${ME}.lock"
LOG_FACILITY='local7'

BUCKET='s3://mofo-techops/deploy_repo'
LOCAL='/mnt/packages/'

(
if flock -n -x 8 # try and obtain lock
then #do the work that needs the lock
    s3cmd sync ${BUCKET} ${LOCAL} # pull down
    if [ $? -eq 0 ]
    then
        logger -s -t ${ME} -p ${LOG_FACILITY}.info "Synced from S3 successfully"
    else
        logger -s -t ${ME} -p ${LOG_FACILITY}.err "Sync from S3 exited w/ non-zero status"
    fi
#    chown -R ubuntu /mnt/packages

else
    logger -s -t ${ME} -p cron.err "Couldn't run, already running"
fi

) 8>${LOCK_FILE} # magic! obtains a file handle for the subshell.
