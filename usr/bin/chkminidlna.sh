#!/bin/sh
#
# check if minidlna files are ok

# where to look for the files
DIR=/mnt/media

# do nothing if this file exists
CHKFILE=${DIR}/.minidlna/files.db

# remove this dir if CHKFILE does not exist
RMTHIS=${DIR}/.minidlna/art_cache

# put what remains here
JUNKDIR=${DIR}/.BAD

# minidlna pidfile
PIDFILE=/var/run/minidlna/minidlna.pid

if [ x$1 != "x--rebuild" -a x$2 != "x--rebuild" ]
then
  # if the file exists only check for the daemon
  if [ -s ${CHKFILE} ]
  then
    if [ x$1 != "x--nodaemon" -a x$2 != "x--nodaemon" ]
    then
      # check if the daemon is running
      ps | grep -v grep | grep -q minidlna && exit 0
      /usr/sbin/minidlna -f /etc/minidlna.conf 
      /mnt/sdb1/myscripts/notify.sh "minidlna started" \
        "minidlna server was not running; launched"
    fi
    exit 0 
  fi 
else
  # forcibly rebuilding everything
  rm -f ${CHKFILE} 
  kill `cat ${PIDFILE}`
#  /mnt/sdb1/myscripts/notify.sh "rebulding minidlna" "${CHKFILE} was removed"
fi

NEWDIR=${JUNKDIR}/AC`/bin/date +%Y%m%d%H%M`

mv ${RMTHIS} ${NEWDIR}
rm -rf ${NEWDIR}

if [ x$1 != "x--rebuild" -a x$2 != "x--rebuild" ]
then
  # only notify if it's not a planned rebuid
  /mnt/sdb1/myscripts/notify.sh "minidlna fixed" "${DIR} folder was removed"
fi

if [ x$1 != "x--nodaemon" -a x$2 != "x--nodaemon" ]
then
  /usr/sbin/minidlna -f /etc/minidlna.conf 
#  /mnt/sdb1/myscripts/notify.sh "minidlna started" "minidlna server launched"
fi
