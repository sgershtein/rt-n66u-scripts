#!/bin/sh

if [ "x$1" = x ] 
then
  echo "Usage: "
  echo " $0 subject text           notify with this subject and text  OR"
  echo " cat file | $0 subject -   notify with this subject, text from stdin"
  exit
fi

#SMTP="mail.planet-a.ru"
SMTP="gmail-smtp-in.l.google.com"
FROM="sg@convert-me.com"
TO="sgershtein@gmail.com"
FROMNAME="Home Router"
TMP="/tmp/notify.tmp"

#echo "From $FROM"
echo "Subject: $1" >$TMP
echo "From: \"$FROMNAME\" <$FROM>" >>$TMP
echo "Date: `date -R`" >>$TMP
echo "" >>$TMP
if [ "x$2" = "x-" ]
then
  cat - >>$TMP
else
  echo $2 >>$TMP
fi
echo "" >>$TMP


cat $TMP | /usr/sbin/sendmail -S"$SMTP" -f"$FROM" $TO
#rm -f $TMP
